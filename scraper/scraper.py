#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Catalog scraper for a public, form-driven forklift-battery catalog.

Given a target (manufacturer, model, voltage[, compartment]) it extracts the full
battery spec sheet, combining Selenium-driven form navigation with direct calls to the
site's AJAX endpoints. Includes rate limiting and exponential-backoff retries.

Configure the target via the CATALOG_BASE_URL environment variable. This repo ships a
placeholder — point it at a public catalog you are authorized to scrape, and always
respect the site's robots.txt and terms of use.
"""

import os
import sys
import io
import csv
import time
import logging

import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.chrome.options import Options

if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)

CATALOG_BASE_URL = os.environ.get("CATALOG_BASE_URL", "https://example-catalog.invalid")
DEFAULT_BATTERY_FAMILY = "Standard Series"

# Maps the catalog's raw input names to our normalized column names.
FIELD_MAP = {
    "voltage": "Voltage_Output",
    "weightmin": "Weight_Min",
    "weightmax": "Weight_Max",
    "cover": "Cover",
    "position": "Position",
    "connector": "Connector",
    "cover_required": "Cover_Required",
    "kwh": "KWH",
    "plate-rating": "Plate_Rating",
    "ah-capacity": "Ah_Capacity",
    "service-weight": "Service_Weight",
    "tray": "Tray",
    "battery-type": "Battery_Type",
    "dimensions": "Battery_Dimensions",
}


class BatterySpecScraper:
    """Scrapes battery spec sheets from a form-driven catalog site."""

    def __init__(self, base_url: str = CATALOG_BASE_URL, headless: bool = False,
                 min_request_interval: float = 2.0):
        self.base_url = base_url.rstrip("/")
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        })
        self.min_request_interval = min_request_interval
        self.last_request_time = None
        self.driver = self._setup_driver(headless=headless)

    # ---- infrastructure -------------------------------------------------

    def _setup_driver(self, headless: bool):
        options = Options()
        if headless:
            options.add_argument("--headless=new")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_experimental_option("excludeSwitches", ["enable-logging"])
        driver = webdriver.Chrome(options=options)
        driver.maximize_window()
        return driver

    def _rate_limit(self):
        """Guarantee a minimum delay between HTTP requests."""
        if self.last_request_time:
            elapsed = time.time() - self.last_request_time
            if elapsed < self.min_request_interval:
                time.sleep(self.min_request_interval - elapsed)
        self.last_request_time = time.time()

    def _safe_request(self, url, params, max_retries=3, timeout=10):
        """GET with rate limiting, 429 handling and exponential backoff."""
        for attempt in range(max_retries):
            try:
                self._rate_limit()
                response = self.session.get(url, params=params, timeout=timeout)
                if response.status_code == 429:
                    wait = (2 ** attempt) * 5
                    logger.warning(f"  rate limited, waiting {wait}s")
                    time.sleep(wait)
                    continue
                return response
            except requests.exceptions.RequestException as e:
                if attempt == max_retries - 1:
                    logger.error(f"  request failed: {e}")
                    raise
                time.sleep(2 ** attempt)
        return None

    # ---- extraction -----------------------------------------------------

    def get_specs_via_api(self, manufacturer, model, voltage, compartment=None,
                          battery_family=None, battery_type=None) -> dict:
        """Hit the catalog's specs endpoint directly and parse the read-only inputs."""
        specs = {}
        try:
            url = f"{self.base_url}/app/assets/php/specs.php"
            params = {
                "manufacturer": manufacturer,
                "model": model,
                "voltage": voltage,
                "onboard_charger": "NO",
                "battery-family": battery_family or DEFAULT_BATTERY_FAMILY,
            }
            if compartment:
                params["compartment"] = compartment
            if battery_type:
                params["battery-type"] = battery_type

            response = self._safe_request(url, params, timeout=10)
            if response and response.status_code == 200 and response.text:
                soup = BeautifulSoup(response.text, "html.parser")
                for input_tag in soup.find_all("input", {"readonly": True}):
                    name = (input_tag.get("name") or "").strip()
                    value = (input_tag.get("value") or "").strip()
                    if name and value:
                        specs[FIELD_MAP.get(name, name)] = value

                pdf_link = soup.find("a", class_="btn-download")
                if pdf_link and pdf_link.get("href"):
                    specs["Drawing_PDF_URL"] = pdf_link.get("href").strip()
        except Exception as e:
            logger.debug(f"  specs endpoint error: {e}")
        return specs

    def extract_battery_specs(self, manufacturer, model, voltage, compartment=None) -> dict:
        """Drive the catalog form with Selenium, then pull specs from the API endpoint."""
        battery_family = DEFAULT_BATTERY_FAMILY
        battery_type = None
        specs = {}
        try:
            self.driver.get(self.base_url)
            time.sleep(3)

            Select(self.driver.find_element(By.ID, "manufacturer")).select_by_visible_text(manufacturer)
            time.sleep(2)
            Select(self.driver.find_element(By.ID, "model")).select_by_visible_text(model)
            time.sleep(1.5)
            Select(self.driver.find_element(By.ID, "voltage")).select_by_visible_text(voltage)
            time.sleep(1.5)

            if compartment and compartment != "N/A":
                try:
                    Select(self.driver.find_element(By.ID, "compartment")).select_by_value(compartment)
                    time.sleep(1.5)
                except Exception as e:
                    logger.debug(f"  could not select compartment: {e}")

            # Discover the available battery family from the form.
            try:
                family_select = Select(self.driver.find_element(By.ID, "battery_family"))
                families = [o.text for o in family_select.options
                            if o.text and o.text.strip() and o.text != "Select Option"]
                if families:
                    battery_family = families[0]
                    family_select.select_by_visible_text(battery_family)
                    time.sleep(1.5)
            except Exception:
                pass
            specs["Battery_Family"] = battery_family

            try:
                battery_type = self.driver.find_element(By.NAME, "battery-type").get_attribute("value")
            except Exception:
                pass

            specs.update(self.get_specs_via_api(
                manufacturer, model, voltage,
                compartment=None if compartment == "N/A" else compartment,
                battery_family=battery_family, battery_type=battery_type,
            ))
        except Exception as e:
            logger.error(f"  extraction error: {e}")
        return specs

    def close(self):
        try:
            self.driver.quit()
        except Exception:
            pass


# Example targets — replace with your own (manufacturer, model, voltage, compartment).
SAMPLE_TARGETS = [
    ("Toyota", "8FGCU25", "48", None),
    ("Hyster", "E50XN", "36", None),
]


def main():
    out_dir = os.path.join(os.path.dirname(__file__), "output")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "specs.csv")

    scraper = BatterySpecScraper(headless=False)
    rows = []
    try:
        for manufacturer, model, voltage, compartment in SAMPLE_TARGETS:
            logger.info(f"Scraping {manufacturer} {model} @ {voltage}V")
            specs = scraper.extract_battery_specs(manufacturer, model, voltage, compartment)
            specs.update({"Manufacturer": manufacturer, "Model": model,
                          "Voltage": voltage, "Compartment_Size": compartment or "N/A"})
            rows.append(specs)
    finally:
        scraper.close()

    if rows:
        fieldnames = sorted({k for r in rows for k in r})
        with open(out_path, "w", newline="", encoding="utf-8-sig") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(rows)
        logger.info(f"Wrote {len(rows)} rows -> {out_path}")


if __name__ == "__main__":
    main()
