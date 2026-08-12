-- ============================================================
-- FORKLIFT BATTERY COMPATIBILITY DATABASE — SCHEMA
-- ============================================================
-- Normalized 5-table model (PostgreSQL / Supabase).
-- Run this first, then load database/sample_data.sql.
-- ============================================================

-- 1. MANUFACTURERS (forklift makers)
CREATE TABLE IF NOT EXISTS manufacturers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_manufacturers_name ON manufacturers(name);

-- 2. EQUIPMENT MODELS (forklift models per manufacturer)
CREATE TABLE IF NOT EXISTS equipment_models (
    id SERIAL PRIMARY KEY,
    manufacturer_id INTEGER NOT NULL REFERENCES manufacturers(id) ON DELETE CASCADE,
    model_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(manufacturer_id, model_name)
);
CREATE INDEX IF NOT EXISTS idx_equipment_models_manufacturer ON equipment_models(manufacturer_id);
CREATE INDEX IF NOT EXISTS idx_equipment_models_name ON equipment_models(model_name);

-- 3. BATTERY TYPES
CREATE TABLE IF NOT EXISTS battery_types (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_battery_types_name ON battery_types(type_name);

-- 4. CONNECTORS
CREATE TABLE IF NOT EXISTS connectors (
    id SERIAL PRIMARY KEY,
    connector_name VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_connectors_name ON connectors(connector_name);

-- 5. BATTERY COMPATIBILITY (main technical table)
CREATE TABLE IF NOT EXISTS battery_compatibility (
    id SERIAL PRIMARY KEY,
    equipment_model_id INTEGER NOT NULL REFERENCES equipment_models(id) ON DELETE CASCADE,
    voltage VARCHAR(50),
    compartment_size VARCHAR(255),
    battery_type_id INTEGER REFERENCES battery_types(id) ON DELETE SET NULL,
    connector_id INTEGER REFERENCES connectors(id) ON DELETE SET NULL,
    battery_family VARCHAR(255),
    voltage_output NUMERIC(10, 2),
    weight_min NUMERIC(10, 2),
    weight_max NUMERIC(10, 2),
    cover VARCHAR(50),
    position VARCHAR(255),
    cover_required VARCHAR(50),
    kwh NUMERIC(10, 2),
    plate_rating NUMERIC(10, 2),
    ah_capacity NUMERIC(10, 2),
    service_weight NUMERIC(10, 2),
    battery_fam VARCHAR(255),
    tray VARCHAR(255),
    battery_dimensions VARCHAR(255),
    drawing_pdf_url TEXT,
    status VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_battery_compatibility_equipment ON battery_compatibility(equipment_model_id);
CREATE INDEX IF NOT EXISTS idx_battery_compatibility_battery_type ON battery_compatibility(battery_type_id);
CREATE INDEX IF NOT EXISTS idx_battery_compatibility_connector ON battery_compatibility(connector_id);
CREATE INDEX IF NOT EXISTS idx_battery_compatibility_voltage ON battery_compatibility(voltage);
CREATE INDEX IF NOT EXISTS idx_battery_compatibility_status ON battery_compatibility(status);

COMMENT ON TABLE manufacturers        IS 'Forklift manufacturers';
COMMENT ON TABLE equipment_models      IS 'Forklift models per manufacturer';
COMMENT ON TABLE battery_types         IS 'Battery types';
COMMENT ON TABLE connectors            IS 'Battery connector types';
COMMENT ON TABLE battery_compatibility IS 'Compatibility records between equipment and batteries';
