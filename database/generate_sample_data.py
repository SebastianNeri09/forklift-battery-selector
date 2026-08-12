#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Generate a small, deterministic, SIMULATED dataset for the schema in schema.sql.

All specs are fabricated for demonstration only — this does NOT reproduce any real
manufacturer catalog. Run it to (re)create database/sample_data.sql:

    python generate_sample_data.py
"""

import os
import random

random.seed(42)  # deterministic output

OUT = os.path.join(os.path.dirname(__file__), "sample_data.sql")

# Public brand names used only as labels; all specs below are invented.
MANUFACTURERS = ["Toyota", "Hyster", "Yale", "Crown", "Raymond", "Clark"]
MODELS = {
    "Toyota": ["8FGCU25", "7FBEU20"],
    "Hyster": ["E50XN", "J40XNT"],
    "Yale": ["ERP040", "GLP050"],
    "Crown": ["FC4500", "SC6000"],
    "Raymond": ["4250", "8410"],
    "Clark": ["ECX25", "GEX40"],
}
VOLTAGES = ["24", "36", "48", "80"]
CONNECTORS = ["SB175 (Anderson)", "SB350 (Anderson)", "Euro DIN 320", "SBE320"]
COVERS = ["Yes", "No"]
POSITIONS = ["Standard", "Offset", "Center"]


def q(s):
    """Quote a SQL string literal."""
    return "'" + str(s).replace("'", "''") + "'"


def compartment(volt):
    w = round(random.uniform(20, 40), 2)
    h = round(random.uniform(18, 32), 2)
    d = round(random.uniform(24, 40), 2)
    return f"{w:.2f} x {h:.2f} x {d:.2f}"


def battery_type_code(volt):
    cells = int(int(volt) / 2)
    amp = random.choice([85, 100, 125, 155, 170])
    plates = random.choice([13, 15, 17, 21, 25])
    return f"{cells}-{amp}-{plates}"


rows = []          # compatibility rows
types = set()
connectors = set()

for manufacturer in MANUFACTURERS:
    for model in MODELS[manufacturer]:
        for volt in random.sample(VOLTAGES, 2):
            for _ in range(random.randint(1, 2)):
                comp = compartment(volt)
                btype = battery_type_code(volt)
                conn = random.choice(CONNECTORS)
                types.add(btype)
                connectors.add(conn)
                ah = random.choice([510, 620, 775, 930, 1085])
                rows.append({
                    "manufacturer": manufacturer, "model": model, "voltage": volt,
                    "compartment_size": comp, "battery_type": btype, "connector": conn,
                    "battery_family": "Standard Series",
                    "voltage_output": f"{float(volt):.2f}",
                    "weight_min": random.randint(1200, 2200),
                    "weight_max": random.randint(2300, 3600),
                    "cover": random.choice(COVERS), "position": random.choice(POSITIONS),
                    "cover_required": random.choice(COVERS),
                    "kwh": round(int(volt) * ah / 1000.0, 2),
                    "plate_rating": random.choice([85, 100, 125, 155]),
                    "ah_capacity": ah, "service_weight": random.randint(2000, 3400),
                    "tray": f"T-{random.randint(100, 999)}",
                    "battery_dimensions": comp, "status": "Complete",
                })

with open(OUT, "w", encoding="utf-8") as f:
    f.write("-- SIMULATED sample data for demonstration only (not a real catalog).\n\n")

    f.write("-- Manufacturers\n")
    for m in MANUFACTURERS:
        f.write(f"INSERT INTO manufacturers (name) VALUES ({q(m)}) ON CONFLICT (name) DO NOTHING;\n")

    f.write("\n-- Equipment models\n")
    for m in MANUFACTURERS:
        for model in MODELS[m]:
            f.write(f"INSERT INTO equipment_models (manufacturer_id, model_name) "
                    f"SELECT id, {q(model)} FROM manufacturers WHERE name = {q(m)} "
                    f"ON CONFLICT (manufacturer_id, model_name) DO NOTHING;\n")

    f.write("\n-- Battery types\n")
    for t in sorted(types):
        f.write(f"INSERT INTO battery_types (type_name) VALUES ({q(t)}) ON CONFLICT (type_name) DO NOTHING;\n")

    f.write("\n-- Connectors\n")
    for c in sorted(connectors):
        f.write(f"INSERT INTO connectors (connector_name) VALUES ({q(c)}) ON CONFLICT (connector_name) DO NOTHING;\n")

    f.write("\n-- Battery compatibility\n")
    for r in rows:
        f.write(
            "INSERT INTO battery_compatibility (\n"
            "  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,\n"
            "  battery_family, voltage_output, weight_min, weight_max, cover, position,\n"
            "  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,\n"
            "  battery_dimensions, status\n"
            ") SELECT em.id,\n"
            f"  {q(r['voltage'])}, {q(r['compartment_size'])}, bt.id, c.id,\n"
            f"  {q(r['battery_family'])}, {r['voltage_output']}, {r['weight_min']}, {r['weight_max']},\n"
            f"  {q(r['cover'])}, {q(r['position'])}, {q(r['cover_required'])}, {r['kwh']},\n"
            f"  {r['plate_rating']}, {r['ah_capacity']}, {r['service_weight']}, {q(r['tray'])},\n"
            f"  {q(r['battery_dimensions'])}, {q(r['status'])}\n"
            "FROM equipment_models em\n"
            f"JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = {q(r['manufacturer'])}\n"
            f"LEFT JOIN battery_types bt ON bt.type_name = {q(r['battery_type'])}\n"
            f"LEFT JOIN connectors c ON c.connector_name = {q(r['connector'])}\n"
            f"WHERE em.model_name = {q(r['model'])};\n\n"
        )

print(f"Wrote {OUT}: {len(MANUFACTURERS)} manufacturers, "
      f"{sum(len(v) for v in MODELS.values())} models, {len(types)} types, "
      f"{len(connectors)} connectors, {len(rows)} compatibility rows")
