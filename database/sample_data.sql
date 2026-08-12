-- SIMULATED sample data for demonstration only (not a real catalog).

-- Manufacturers
INSERT INTO manufacturers (name) VALUES ('Toyota') ON CONFLICT (name) DO NOTHING;
INSERT INTO manufacturers (name) VALUES ('Hyster') ON CONFLICT (name) DO NOTHING;
INSERT INTO manufacturers (name) VALUES ('Yale') ON CONFLICT (name) DO NOTHING;
INSERT INTO manufacturers (name) VALUES ('Crown') ON CONFLICT (name) DO NOTHING;
INSERT INTO manufacturers (name) VALUES ('Raymond') ON CONFLICT (name) DO NOTHING;
INSERT INTO manufacturers (name) VALUES ('Clark') ON CONFLICT (name) DO NOTHING;

-- Equipment models
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, '8FGCU25' FROM manufacturers WHERE name = 'Toyota' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, '7FBEU20' FROM manufacturers WHERE name = 'Toyota' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, 'E50XN' FROM manufacturers WHERE name = 'Hyster' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, 'J40XNT' FROM manufacturers WHERE name = 'Hyster' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, 'ERP040' FROM manufacturers WHERE name = 'Yale' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, 'GLP050' FROM manufacturers WHERE name = 'Yale' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, 'FC4500' FROM manufacturers WHERE name = 'Crown' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, 'SC6000' FROM manufacturers WHERE name = 'Crown' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, '4250' FROM manufacturers WHERE name = 'Raymond' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, '8410' FROM manufacturers WHERE name = 'Raymond' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, 'ECX25' FROM manufacturers WHERE name = 'Clark' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;
INSERT INTO equipment_models (manufacturer_id, model_name) SELECT id, 'GEX40' FROM manufacturers WHERE name = 'Clark' ON CONFLICT (manufacturer_id, model_name) DO NOTHING;

-- Battery types
INSERT INTO battery_types (type_name) VALUES ('12-125-17') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('12-125-25') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('12-155-13') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('12-155-15') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('12-170-13') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('12-85-15') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('18-100-13') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('18-100-17') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('18-100-21') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('18-125-17') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('18-125-21') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('18-155-21') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('18-170-21') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('18-85-17') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('18-85-21') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('18-85-25') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('24-100-17') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('24-100-21') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('24-100-25') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('24-155-17') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('24-155-21') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('24-170-13') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('24-85-15') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('24-85-21') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('40-100-13') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('40-100-21') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('40-155-25') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('40-170-15') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('40-170-25') ON CONFLICT (type_name) DO NOTHING;
INSERT INTO battery_types (type_name) VALUES ('40-85-17') ON CONFLICT (type_name) DO NOTHING;

-- Connectors
INSERT INTO connectors (connector_name) VALUES ('Euro DIN 320') ON CONFLICT (connector_name) DO NOTHING;
INSERT INTO connectors (connector_name) VALUES ('SB175 (Anderson)') ON CONFLICT (connector_name) DO NOTHING;
INSERT INTO connectors (connector_name) VALUES ('SB350 (Anderson)') ON CONFLICT (connector_name) DO NOTHING;
INSERT INTO connectors (connector_name) VALUES ('SBE320') ON CONFLICT (connector_name) DO NOTHING;

-- Battery compatibility
INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '24', '24.90 x 19.95 x 25.64', bt.id, c.id,
  'Standard Series', 24.00, 1230, 2491,
  'Yes', 'Standard', 'Yes', 12.24,
  100, 510, 3330, 'T-818',
  '24.90 x 19.95 x 25.64', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Toyota'
LEFT JOIN battery_types bt ON bt.type_name = '12-170-13'
LEFT JOIN connectors c ON c.connector_name = 'SBE320'
WHERE em.model_name = '8FGCU25';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '24', '30.90 x 21.09 x 33.43', bt.id, c.id,
  'Standard Series', 24.00, 1484, 2618,
  'Yes', 'Offset', 'Yes', 18.6,
  85, 775, 2778, 'T-199',
  '30.90 x 21.09 x 33.43', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Toyota'
LEFT JOIN battery_types bt ON bt.type_name = '12-85-15'
LEFT JOIN connectors c ON c.connector_name = 'SBE320'
WHERE em.model_name = '8FGCU25';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '80', '36.95 x 26.45 x 36.91', bt.id, c.id,
  'Standard Series', 80.00, 1280, 3430,
  'No', 'Center', 'No', 74.4,
  100, 930, 2142, 'T-146',
  '36.95 x 26.45 x 36.91', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Toyota'
LEFT JOIN battery_types bt ON bt.type_name = '40-155-25'
LEFT JOIN connectors c ON c.connector_name = 'SB175 (Anderson)'
WHERE em.model_name = '8FGCU25';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '80', '33.23 x 28.82 x 39.76', bt.id, c.id,
  'Standard Series', 80.00, 1664, 3047,
  'Yes', 'Offset', 'No', 62.0,
  100, 775, 3372, 'T-373',
  '33.23 x 28.82 x 39.76', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Toyota'
LEFT JOIN battery_types bt ON bt.type_name = '40-100-13'
LEFT JOIN connectors c ON c.connector_name = 'SBE320'
WHERE em.model_name = '8FGCU25';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '24', '30.68 x 21.43 x 31.40', bt.id, c.id,
  'Standard Series', 24.00, 2063, 2414,
  'Yes', 'Standard', 'No', 18.6,
  155, 775, 2548, 'T-167',
  '30.68 x 21.43 x 31.40', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Toyota'
LEFT JOIN battery_types bt ON bt.type_name = '12-125-25'
LEFT JOIN connectors c ON c.connector_name = 'SB350 (Anderson)'
WHERE em.model_name = '7FBEU20';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '38.26 x 25.94 x 35.49', bt.id, c.id,
  'Standard Series', 48.00, 1346, 2842,
  'Yes', 'Standard', 'No', 44.64,
  155, 930, 3195, 'T-508',
  '38.26 x 25.94 x 35.49', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Toyota'
LEFT JOIN battery_types bt ON bt.type_name = '24-100-21'
LEFT JOIN connectors c ON c.connector_name = 'SBE320'
WHERE em.model_name = '7FBEU20';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '30.19 x 19.27 x 24.75', bt.id, c.id,
  'Standard Series', 48.00, 1810, 2430,
  'No', 'Offset', 'No', 44.64,
  125, 930, 3133, 'T-981',
  '30.19 x 19.27 x 24.75', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Hyster'
LEFT JOIN battery_types bt ON bt.type_name = '24-85-15'
LEFT JOIN connectors c ON c.connector_name = 'SB350 (Anderson)'
WHERE em.model_name = 'E50XN';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '24', '33.61 x 19.60 x 38.16', bt.id, c.id,
  'Standard Series', 24.00, 1645, 2623,
  'No', 'Standard', 'No', 18.6,
  100, 775, 3039, 'T-208',
  '33.61 x 19.60 x 38.16', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Hyster'
LEFT JOIN battery_types bt ON bt.type_name = '12-125-17'
LEFT JOIN connectors c ON c.connector_name = 'SB175 (Anderson)'
WHERE em.model_name = 'E50XN';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '23.06 x 28.68 x 32.63', bt.id, c.id,
  'Standard Series', 48.00, 1219, 2529,
  'No', 'Offset', 'Yes', 44.64,
  85, 930, 2493, 'T-999',
  '23.06 x 28.68 x 32.63', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Hyster'
LEFT JOIN battery_types bt ON bt.type_name = '24-170-13'
LEFT JOIN connectors c ON c.connector_name = 'Euro DIN 320'
WHERE em.model_name = 'J40XNT';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '80', '21.71 x 24.80 x 25.11', bt.id, c.id,
  'Standard Series', 80.00, 2169, 3425,
  'Yes', 'Offset', 'No', 74.4,
  100, 930, 3104, 'T-873',
  '21.71 x 24.80 x 25.11', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Hyster'
LEFT JOIN battery_types bt ON bt.type_name = '40-170-15'
LEFT JOIN connectors c ON c.connector_name = 'SB350 (Anderson)'
WHERE em.model_name = 'J40XNT';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '36', '27.98 x 27.40 x 29.97', bt.id, c.id,
  'Standard Series', 36.00, 1430, 2431,
  'No', 'Standard', 'Yes', 22.32,
  100, 620, 2014, 'T-172',
  '27.98 x 27.40 x 29.97', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Yale'
LEFT JOIN battery_types bt ON bt.type_name = '18-170-21'
LEFT JOIN connectors c ON c.connector_name = 'SB175 (Anderson)'
WHERE em.model_name = 'ERP040';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '36', '34.16 x 18.82 x 25.08', bt.id, c.id,
  'Standard Series', 36.00, 1443, 2870,
  'No', 'Standard', 'Yes', 39.06,
  155, 1085, 2497, 'T-903',
  '34.16 x 18.82 x 25.08', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Yale'
LEFT JOIN battery_types bt ON bt.type_name = '18-85-17'
LEFT JOIN connectors c ON c.connector_name = 'SB175 (Anderson)'
WHERE em.model_name = 'ERP040';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '36.15 x 20.67 x 25.55', bt.id, c.id,
  'Standard Series', 48.00, 1678, 2410,
  'Yes', 'Standard', 'No', 44.64,
  125, 930, 2223, 'T-354',
  '36.15 x 20.67 x 25.55', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Yale'
LEFT JOIN battery_types bt ON bt.type_name = '24-155-17'
LEFT JOIN connectors c ON c.connector_name = 'SBE320'
WHERE em.model_name = 'ERP040';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '23.83 x 25.51 x 26.24', bt.id, c.id,
  'Standard Series', 48.00, 2095, 2454,
  'No', 'Center', 'Yes', 29.76,
  85, 620, 3335, 'T-653',
  '23.83 x 25.51 x 26.24', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Yale'
LEFT JOIN battery_types bt ON bt.type_name = '24-100-17'
LEFT JOIN connectors c ON c.connector_name = 'SBE320'
WHERE em.model_name = 'ERP040';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '24', '23.33 x 24.80 x 27.42', bt.id, c.id,
  'Standard Series', 24.00, 1202, 3099,
  'No', 'Offset', 'No', 22.32,
  155, 930, 3138, 'T-777',
  '23.33 x 24.80 x 27.42', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Yale'
LEFT JOIN battery_types bt ON bt.type_name = '12-155-13'
LEFT JOIN connectors c ON c.connector_name = 'SB350 (Anderson)'
WHERE em.model_name = 'GLP050';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '80', '23.10 x 22.15 x 39.50', bt.id, c.id,
  'Standard Series', 80.00, 1258, 2402,
  'No', 'Center', 'Yes', 62.0,
  85, 775, 3040, 'T-182',
  '23.10 x 22.15 x 39.50', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Yale'
LEFT JOIN battery_types bt ON bt.type_name = '40-170-25'
LEFT JOIN connectors c ON c.connector_name = 'SB175 (Anderson)'
WHERE em.model_name = 'GLP050';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '80', '37.03 x 18.96 x 25.09', bt.id, c.id,
  'Standard Series', 80.00, 1452, 3485,
  'Yes', 'Center', 'Yes', 86.8,
  155, 1085, 3346, 'T-697',
  '37.03 x 18.96 x 25.09', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Yale'
LEFT JOIN battery_types bt ON bt.type_name = '40-100-21'
LEFT JOIN connectors c ON c.connector_name = 'SB175 (Anderson)'
WHERE em.model_name = 'GLP050';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '33.39 x 22.40 x 28.25', bt.id, c.id,
  'Standard Series', 48.00, 2151, 2448,
  'Yes', 'Offset', 'Yes', 37.2,
  85, 775, 3101, 'T-318',
  '33.39 x 22.40 x 28.25', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Crown'
LEFT JOIN battery_types bt ON bt.type_name = '24-100-17'
LEFT JOIN connectors c ON c.connector_name = 'SBE320'
WHERE em.model_name = 'FC4500';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '36', '22.65 x 22.89 x 25.10', bt.id, c.id,
  'Standard Series', 36.00, 1648, 3412,
  'No', 'Center', 'Yes', 22.32,
  125, 620, 3358, 'T-206',
  '22.65 x 22.89 x 25.10', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Crown'
LEFT JOIN battery_types bt ON bt.type_name = '18-100-17'
LEFT JOIN connectors c ON c.connector_name = 'Euro DIN 320'
WHERE em.model_name = 'FC4500';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '36', '38.78 x 19.88 x 25.85', bt.id, c.id,
  'Standard Series', 36.00, 1488, 3538,
  'Yes', 'Center', 'No', 27.9,
  100, 775, 3298, 'T-973',
  '38.78 x 19.88 x 25.85', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Crown'
LEFT JOIN battery_types bt ON bt.type_name = '18-85-25'
LEFT JOIN connectors c ON c.connector_name = 'SB350 (Anderson)'
WHERE em.model_name = 'FC4500';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '25.02 x 30.71 x 24.81', bt.id, c.id,
  'Standard Series', 48.00, 1541, 2567,
  'No', 'Standard', 'No', 24.48,
  155, 510, 3148, 'T-109',
  '25.02 x 30.71 x 24.81', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Crown'
LEFT JOIN battery_types bt ON bt.type_name = '24-155-17'
LEFT JOIN connectors c ON c.connector_name = 'SB175 (Anderson)'
WHERE em.model_name = 'SC6000';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '22.24 x 31.23 x 35.06', bt.id, c.id,
  'Standard Series', 48.00, 1796, 3431,
  'Yes', 'Offset', 'Yes', 37.2,
  85, 775, 2631, 'T-473',
  '22.24 x 31.23 x 35.06', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Crown'
LEFT JOIN battery_types bt ON bt.type_name = '24-100-25'
LEFT JOIN connectors c ON c.connector_name = 'SB175 (Anderson)'
WHERE em.model_name = 'SC6000';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '80', '37.98 x 20.94 x 27.99', bt.id, c.id,
  'Standard Series', 80.00, 1967, 2616,
  'Yes', 'Standard', 'Yes', 86.8,
  155, 1085, 2050, 'T-283',
  '37.98 x 20.94 x 27.99', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Crown'
LEFT JOIN battery_types bt ON bt.type_name = '40-85-17'
LEFT JOIN connectors c ON c.connector_name = 'SBE320'
WHERE em.model_name = 'SC6000';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '25.34 x 29.02 x 25.73', bt.id, c.id,
  'Standard Series', 48.00, 2036, 3242,
  'No', 'Offset', 'Yes', 29.76,
  100, 620, 2048, 'T-775',
  '25.34 x 29.02 x 25.73', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Raymond'
LEFT JOIN battery_types bt ON bt.type_name = '24-85-21'
LEFT JOIN connectors c ON c.connector_name = 'SB350 (Anderson)'
WHERE em.model_name = '4250';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '36', '27.97 x 21.90 x 25.11', bt.id, c.id,
  'Standard Series', 36.00, 1539, 2356,
  'Yes', 'Offset', 'Yes', 39.06,
  125, 1085, 2078, 'T-211',
  '27.97 x 21.90 x 25.11', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Raymond'
LEFT JOIN battery_types bt ON bt.type_name = '18-125-17'
LEFT JOIN connectors c ON c.connector_name = 'SBE320'
WHERE em.model_name = '4250';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '80', '28.73 x 31.78 x 25.85', bt.id, c.id,
  'Standard Series', 80.00, 1925, 3193,
  'Yes', 'Center', 'Yes', 40.8,
  125, 510, 2883, 'T-171',
  '28.73 x 31.78 x 25.85', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Raymond'
LEFT JOIN battery_types bt ON bt.type_name = '40-170-15'
LEFT JOIN connectors c ON c.connector_name = 'Euro DIN 320'
WHERE em.model_name = '8410';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '80', '38.98 x 30.89 x 33.97', bt.id, c.id,
  'Standard Series', 80.00, 1534, 3124,
  'No', 'Center', 'Yes', 74.4,
  100, 930, 2861, 'T-780',
  '38.98 x 30.89 x 33.97', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Raymond'
LEFT JOIN battery_types bt ON bt.type_name = '40-85-17'
LEFT JOIN connectors c ON c.connector_name = 'Euro DIN 320'
WHERE em.model_name = '8410';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '36', '33.55 x 30.64 x 33.85', bt.id, c.id,
  'Standard Series', 36.00, 1493, 2730,
  'No', 'Center', 'No', 27.9,
  155, 775, 2904, 'T-552',
  '33.55 x 30.64 x 33.85', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Raymond'
LEFT JOIN battery_types bt ON bt.type_name = '18-125-21'
LEFT JOIN connectors c ON c.connector_name = 'SB175 (Anderson)'
WHERE em.model_name = '8410';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '36', '33.51 x 25.16 x 36.70', bt.id, c.id,
  'Standard Series', 36.00, 1879, 3596,
  'No', 'Standard', 'Yes', 39.06,
  125, 1085, 2460, 'T-925',
  '33.51 x 25.16 x 36.70', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Raymond'
LEFT JOIN battery_types bt ON bt.type_name = '18-100-13'
LEFT JOIN connectors c ON c.connector_name = 'Euro DIN 320'
WHERE em.model_name = '8410';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '36', '20.92 x 31.78 x 33.78', bt.id, c.id,
  'Standard Series', 36.00, 1399, 3086,
  'No', 'Offset', 'Yes', 39.06,
  100, 1085, 3343, 'T-804',
  '20.92 x 31.78 x 33.78', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Clark'
LEFT JOIN battery_types bt ON bt.type_name = '18-85-21'
LEFT JOIN connectors c ON c.connector_name = 'SBE320'
WHERE em.model_name = 'ECX25';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '24', '37.85 x 30.05 x 38.17', bt.id, c.id,
  'Standard Series', 24.00, 1675, 2402,
  'Yes', 'Standard', 'No', 26.04,
  100, 1085, 2951, 'T-783',
  '37.85 x 30.05 x 38.17', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Clark'
LEFT JOIN battery_types bt ON bt.type_name = '12-155-15'
LEFT JOIN connectors c ON c.connector_name = 'SB350 (Anderson)'
WHERE em.model_name = 'ECX25';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '36.61 x 25.67 x 38.36', bt.id, c.id,
  'Standard Series', 48.00, 2060, 2867,
  'No', 'Center', 'Yes', 29.76,
  125, 620, 2900, 'T-179',
  '36.61 x 25.67 x 38.36', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Clark'
LEFT JOIN battery_types bt ON bt.type_name = '24-155-21'
LEFT JOIN connectors c ON c.connector_name = 'Euro DIN 320'
WHERE em.model_name = 'GEX40';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '48', '34.27 x 21.28 x 29.37', bt.id, c.id,
  'Standard Series', 48.00, 1436, 3084,
  'Yes', 'Center', 'Yes', 29.76,
  85, 620, 2849, 'T-517',
  '34.27 x 21.28 x 29.37', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Clark'
LEFT JOIN battery_types bt ON bt.type_name = '24-170-13'
LEFT JOIN connectors c ON c.connector_name = 'SB350 (Anderson)'
WHERE em.model_name = 'GEX40';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '36', '30.85 x 23.82 x 27.31', bt.id, c.id,
  'Standard Series', 36.00, 1589, 3276,
  'Yes', 'Offset', 'No', 39.06,
  155, 1085, 2858, 'T-651',
  '30.85 x 23.82 x 27.31', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Clark'
LEFT JOIN battery_types bt ON bt.type_name = '18-155-21'
LEFT JOIN connectors c ON c.connector_name = 'SB175 (Anderson)'
WHERE em.model_name = 'GEX40';

INSERT INTO battery_compatibility (
  equipment_model_id, voltage, compartment_size, battery_type_id, connector_id,
  battery_family, voltage_output, weight_min, weight_max, cover, position,
  cover_required, kwh, plate_rating, ah_capacity, service_weight, tray,
  battery_dimensions, status
) SELECT em.id,
  '36', '34.95 x 25.65 x 33.65', bt.id, c.id,
  'Standard Series', 36.00, 1646, 3294,
  'Yes', 'Offset', 'No', 27.9,
  155, 775, 2338, 'T-960',
  '34.95 x 25.65 x 33.65', 'Complete'
FROM equipment_models em
JOIN manufacturers m ON em.manufacturer_id = m.id AND m.name = 'Clark'
LEFT JOIN battery_types bt ON bt.type_name = '18-100-21'
LEFT JOIN connectors c ON c.connector_name = 'SB350 (Anderson)'
WHERE em.model_name = 'GEX40';

