#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
ETL: read scraped battery CSVs and emit idempotent INSERT SQL for the schema in
database/schema.sql (manufacturers, equipment_models, battery_types, connectors,
battery_compatibility).

Usage:
    python build_sql.py --input ./output --output insert_all_data.sql
"""

import sys
import io
import re
import argparse
from pathlib import Path

import pandas as pd

if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")


def escape_sql_string(value):
    """Quote/escape a string for SQL, or return NULL for empty/NaN."""
    if pd.isna(value) or str(value).strip() == "":
        return "NULL"
    return "'" + str(value).strip().replace("'", "''") + "'"


def clean_numeric(value):
    """Strip common units (lbs, V) and return a numeric literal or NULL."""
    if pd.isna(value) or str(value).strip() == "":
        return "NULL"
    s = re.sub(r"\s*(lbs|V|v)\s*$", "", str(value).strip(), flags=re.IGNORECASE)
    try:
        return str(float(s))
    except ValueError:
        return "NULL"


def process_csvs_to_sql(csv_dir: Path, output_file: Path):
    csv_files = sorted(f for f in csv_dir.glob("*.csv") if not f.name.startswith("intermediate"))
    print(f"CSV files found: {len(csv_files)}")

    manufacturers, models, battery_types, connectors = set(), set(), set(), set()
    records = []

    for i, csv_file in enumerate(csv_files, 1):
        print(f"[{i}/{len(csv_files)}] {csv_file.name}")
        try:
            df = pd.read_csv(csv_file, encoding="utf-8-sig")
        except Exception as e:
            print(f"  ERROR: {e}")
            continue

        for _, row in df.iterrows():
            status = str(row.get("Status", "")).strip()
            if status.lower() == "no data":
                continue

            manufacturer = str(row.get("Manufacturer", "")).strip()
            model = str(row.get("Model", "")).strip()
            if not manufacturer or not model:
                continue

            battery_type = str(row.get("Battery_Type", "")).strip()
            connector = str(row.get("Connector", "")).strip()

            manufacturers.add(manufacturer)
            models.add((manufacturer, model))
            if battery_type.lower() not in ("", "nan", "none"):
                battery_types.add(battery_type)
            if connector.lower() not in ("", "nan", "none"):
                connectors.add(connector)

            records.append({
                "manufacturer": manufacturer, "model": model,
                "voltage": str(row.get("Voltage", "")).strip(),
                "compartment_size": str(row.get("Compartment_Size", "")).strip(),
                "battery_family": row.get("Battery_Family", ""),
                "voltage_output": row.get("Voltage_Output", ""),
                "weight_min": row.get("Weight_Min", ""),
                "weight_max": row.get("Weight_Max", ""),
                "cover": row.get("Cover", ""), "position": row.get("Position", ""),
                "connector": connector, "cover_required": row.get("Cover_Required", ""),
                "kwh": row.get("KWH", ""), "plate_rating": row.get("Plate_Rating", ""),
                "ah_capacity": row.get("Ah_Capacity", ""),
                "service_weight": row.get("Service_Weight", ""),
                "battery_fam": row.get("battery-fam", ""),
                "battery_type": battery_type, "tray": row.get("Tray", ""),
                "battery_dimensions": row.get("Battery_Dimensions", ""),
                "drawing_pdf_url": row.get("Drawing_PDF_URL", ""), "status": status,
            })

    print(f"\nManufacturers: {len(manufacturers)} | Models: {len(models)} | "
          f"Types: {len(battery_types)} | Connectors: {len(connectors)} | "
          f"Compatibility rows: {len(records)}")

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("-- Auto-generated battery compatibility data\n\n")

        f.write("-- 1. MANUFACTURERS\n")
        for m in sorted(manufacturers):
            f.write(f"INSERT INTO manufacturers (name) VALUES ({escape_sql_string(m)}) "
                    f"ON CONFLICT (name) DO NOTHING;\n")

        f.write("\n-- 2. EQUIPMENT MODELS\n")
        for manufacturer, model in sorted(models):
            f.write(f"INSERT INTO equipment_models (manufacturer_id, model_name) "
                    f"SELECT id, {escape_sql_string(model)} FROM manufacturers "
                    f"WHERE name = {escape_sql_string(manufacturer)} "
                    f"ON CONFLICT (manufacturer_id, model_name) DO NOTHING;\n")

        f.write("\n-- 3. BATTERY TYPES\n")
        for t in sorted(battery_types):
            f.write(f"INSERT INTO battery_types (type_name) VALUES ({escape_sql_string(t)}) "
                    f"ON CONFLICT (type_name) DO NOTHING;\n")

        f.write("\n-- 4. CONNECTORS\n")
        for c in sorted(connectors):
            f.write(f"INSERT INTO connectors (connector_name) VALUES ({escape_sql_string(c)}) "
                    f"ON CONFLICT (connector_name) DO NOTHING;\n")

        f.write("\n-- 5. BATTERY COMPATIBILITY\n")
        for r in records:
            f.write(
                "INSERT INTO battery_compatibility (\n"
                "  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,\n"
                "  battery_family, voltage_output, weight_min, weight_max, cover, position,\n"
                "  cover_required, kwh, plate_rating, ah_capacity, service_weight, battery_fam,\n"
                "  tray, battery_dimensions, drawing_pdf_url, status\n"
                ") SELECT em.id,\n"
                f"  {escape_sql_string(r['voltage'])}, {escape_sql_string(r['compartment_size'])},\n"
                "  bt.id, c.id,\n"
                f"  {escape_sql_string(r['battery_family'])}, {clean_numeric(r['voltage_output'])},\n"
                f"  {clean_numeric(r['weight_min'])}, {clean_numeric(r['weight_max'])},\n"
                f"  {escape_sql_string(r['cover'])}, {escape_sql_string(r['position'])},\n"
                f"  {escape_sql_string(r['cover_required'])}, {clean_numeric(r['kwh'])},\n"
                f"  {clean_numeric(r['plate_rating'])}, {clean_numeric(r['ah_capacity'])},\n"
                f"  {clean_numeric(r['service_weight'])}, {escape_sql_string(r['battery_fam'])},\n"
                f"  {escape_sql_string(r['tray'])}, {escape_sql_string(r['battery_dimensions'])},\n"
                f"  {escape_sql_string(r['drawing_pdf_url'])}, {escape_sql_string(r['status'])}\n"
                "FROM equipment_models em\n"
                f"JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = {escape_sql_string(r['manufacturer'])}\n"
                f"LEFT JOIN battery_types bt ON bt.type_name = {escape_sql_string(r['battery_type'])}\n"
                f"LEFT JOIN connectors c ON c.connector_name = {escape_sql_string(r['connector'])}\n"
                f"WHERE em.model_name = {escape_sql_string(r['model'])};\n\n"
            )

    size_mb = output_file.stat().st_size / 1024 / 1024
    print(f"\nWrote {output_file} ({size_mb:.2f} MB)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build INSERT SQL from scraped battery CSVs.")
    parser.add_argument("--input", default="./output", help="folder with scraped *.csv files")
    parser.add_argument("--output", default="insert_all_data.sql", help="output .sql path")
    args = parser.parse_args()
    process_csvs_to_sql(Path(args.input), Path(args.output))
