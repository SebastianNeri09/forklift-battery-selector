// ============================================================
// SUPABASE CONFIG
// ============================================================
// Replace with your own project's values (see .env.example).
// The anon key is public-by-design but only safe with RLS enabled
// (SELECT-only policy for the `anon` role). Never put the service_role
// key or the database password here.
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';

// Where the "Request a quote" button should point (your own form / CRM / mailto).
const QUOTE_URL = '#';

const { createClient } = supabase;
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ============================================================
// DOM
// ============================================================
const manufacturerSelect = document.getElementById('manufacturer');
const modelSelect = document.getElementById('model');
const voltageSelect = document.getElementById('voltage');
const compartmentSelect = document.getElementById('compartment');
const searchBtn = document.getElementById('searchBtn');
const resultsDiv = document.getElementById('results');
const noResultsDiv = document.getElementById('noResults');
const loaderDiv = document.getElementById('loader');
const batteryDetailsDiv = document.getElementById('batteryDetails');

// ============================================================
// INIT
// ============================================================
document.addEventListener('DOMContentLoaded', async () => {
    console.log('🚀 Iniciando Selector de Baterías');
    await loadStatistics();
    await loadManufacturers();

    manufacturerSelect.addEventListener('change', handleManufacturerChange);
    modelSelect.addEventListener('change', handleModelChange);
    voltageSelect.addEventListener('change', handleVoltageChange);
    compartmentSelect.addEventListener('change', handleCompartmentChange);
    searchBtn.addEventListener('click', searchBattery);
});

// ============================================================
// STATS
// ============================================================
async function loadStatistics() {
    try {
        const { count: manufacturersCount } = await supabaseClient
            .from('manufacturers').select('*', { count: 'exact', head: true });
        const { count: modelsCount } = await supabaseClient
            .from('equipment_models').select('*', { count: 'exact', head: true });
        const { count: batteryTypesCount } = await supabaseClient
            .from('battery_types').select('*', { count: 'exact', head: true });
        const { count: recordsCount } = await supabaseClient
            .from('battery_compatibility').select('*', { count: 'exact', head: true });

        document.getElementById('totalManufacturers').textContent = manufacturersCount || '-';
        document.getElementById('totalModels').textContent = modelsCount || '-';
        document.getElementById('totalBatteryTypes').textContent = batteryTypesCount || '-';
        document.getElementById('totalRecords').textContent = recordsCount || '-';
    } catch (error) {
        console.error('Error loading statistics:', error);
    }
}

// ============================================================
// MANUFACTURERS
// ============================================================
async function loadManufacturers() {
    try {
        const { data, error } = await supabaseClient
            .from('manufacturers').select('id, name').order('name');
        if (error) throw error;

        manufacturerSelect.innerHTML = '<option value="">Selecciona un fabricante...</option>';
        data.forEach(manufacturer => {
            const option = document.createElement('option');
            option.value = manufacturer.id;
            option.textContent = manufacturer.name;
            manufacturerSelect.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading manufacturers:', error);
        alert('Error al cargar fabricantes. Revisa la consola.');
    }
}

// ============================================================
// CASCADE: manufacturer -> model
// ============================================================
async function handleManufacturerChange() {
    const manufacturerId = manufacturerSelect.value;

    modelSelect.innerHTML = '<option value="">Cargando modelos...</option>';
    modelSelect.disabled = true;
    voltageSelect.innerHTML = '<option value="">Primero selecciona un modelo</option>';
    voltageSelect.disabled = true;
    compartmentSelect.innerHTML = '<option value="">Primero selecciona un voltaje</option>';
    compartmentSelect.disabled = true;
    searchBtn.disabled = true;
    hideResults();

    if (!manufacturerId) {
        modelSelect.innerHTML = '<option value="">Primero selecciona un fabricante</option>';
        return;
    }

    try {
        const { data, error } = await supabaseClient
            .from('equipment_models').select('id, model_name')
            .eq('manufacturer_id', manufacturerId).order('model_name');
        if (error) throw error;

        modelSelect.innerHTML = '<option value="">Selecciona un modelo...</option>';
        data.forEach(model => {
            const option = document.createElement('option');
            option.value = model.id;
            option.textContent = model.model_name;
            modelSelect.appendChild(option);
        });
        modelSelect.disabled = false;
    } catch (error) {
        console.error('Error loading models:', error);
        modelSelect.innerHTML = '<option value="">Error cargando modelos</option>';
    }
}

// ============================================================
// CASCADE: model -> voltage
// ============================================================
async function handleModelChange() {
    const modelId = modelSelect.value;

    voltageSelect.innerHTML = '<option value="">Cargando voltajes...</option>';
    voltageSelect.disabled = true;
    compartmentSelect.innerHTML = '<option value="">Primero selecciona un voltaje</option>';
    compartmentSelect.disabled = true;
    searchBtn.disabled = true;
    hideResults();

    if (!modelId) {
        voltageSelect.innerHTML = '<option value="">Primero selecciona un modelo</option>';
        return;
    }

    try {
        const { data, error } = await supabaseClient
            .from('battery_compatibility').select('voltage')
            .eq('equipment_model_id', modelId).not('voltage', 'is', null).order('voltage');
        if (error) throw error;

        const uniqueVoltages = [...new Set(data.map(item => item.voltage))];
        voltageSelect.innerHTML = '<option value="">Selecciona un voltaje...</option>';
        uniqueVoltages.forEach(voltage => {
            const option = document.createElement('option');
            option.value = voltage;
            option.textContent = voltage;
            voltageSelect.appendChild(option);
        });
        voltageSelect.disabled = false;
    } catch (error) {
        console.error('Error loading voltages:', error);
        voltageSelect.innerHTML = '<option value="">Error cargando voltajes</option>';
    }
}

// ============================================================
// CASCADE: voltage -> compartment
// ============================================================
async function handleVoltageChange() {
    const modelId = modelSelect.value;
    const voltage = voltageSelect.value;

    compartmentSelect.innerHTML = '<option value="">Cargando compartimientos...</option>';
    compartmentSelect.disabled = true;
    searchBtn.disabled = true;
    hideResults();

    if (!voltage) {
        compartmentSelect.innerHTML = '<option value="">Primero selecciona un voltaje</option>';
        return;
    }

    try {
        const { data, error } = await supabaseClient
            .from('battery_compatibility').select('compartment_size')
            .eq('equipment_model_id', modelId).eq('voltage', voltage)
            .not('compartment_size', 'is', null).order('compartment_size');
        if (error) throw error;

        const uniqueCompartments = [...new Set(data.map(item => item.compartment_size))];
        compartmentSelect.innerHTML = '<option value="">Selecciona un compartimiento...</option>';
        uniqueCompartments.forEach(compartment => {
            const option = document.createElement('option');
            option.value = compartment;
            option.textContent = compartment;
            compartmentSelect.appendChild(option);
        });
        compartmentSelect.disabled = false;
    } catch (error) {
        console.error('Error loading compartments:', error);
        compartmentSelect.innerHTML = '<option value="">Error cargando compartimientos</option>';
    }
}

function handleCompartmentChange() {
    searchBtn.disabled = !compartmentSelect.value;
    hideResults();
}

// ============================================================
// SEARCH
// ============================================================
async function searchBattery() {
    const modelId = modelSelect.value;
    const voltage = voltageSelect.value;
    const compartment = compartmentSelect.value;

    showLoader();
    try {
        const { data, error } = await supabaseClient
            .from('battery_compatibility')
            .select(`
                *,
                equipment_model:equipment_models(model_name, manufacturer:manufacturers(name)),
                battery_type:battery_types(type_name),
                connector:connectors(connector_name)
            `)
            .eq('equipment_model_id', modelId)
            .eq('voltage', voltage)
            .eq('compartment_size', compartment)
            .limit(1);
        if (error) throw error;

        if (data && data.length > 0) {
            displayResults(data[0]);
        } else {
            displayNoResults();
        }
    } catch (error) {
        console.error('Error searching battery:', error);
        displayNoResults();
    }
}

// ============================================================
// RENDER
// ============================================================
function displayResults(battery) {
    hideLoader();
    batteryDetailsDiv.innerHTML = '';

    const details = [
        { label: 'Tipo de Batería', value: battery.battery_type?.type_name || 'N/A', highlight: true },
        { label: 'Voltaje', value: `${battery.voltage_output || 'N/A'} V` },
        { label: 'Capacidad (Ah)', value: battery.ah_capacity || 'N/A' },
        { label: 'KWH', value: battery.kwh || 'N/A' },
        { label: 'Peso Mínimo', value: `${battery.weight_min || 'N/A'} lbs` },
        { label: 'Peso Máximo', value: `${battery.weight_max || 'N/A'} lbs` },
        { label: 'Peso de Servicio', value: `${battery.service_weight || 'N/A'} lbs` },
        { label: 'Conector', value: battery.connector?.connector_name || 'N/A' },
        { label: 'Cover', value: battery.cover || 'N/A' },
        { label: 'Posición', value: battery.position || 'N/A' },
        { label: 'Cover Requerido', value: battery.cover_required || 'N/A' },
        { label: 'Familia de Batería', value: battery.battery_family || 'N/A' },
        { label: 'Tray', value: battery.tray || 'N/A' },
        { label: 'Dimensiones', value: battery.battery_dimensions || 'N/A' },
        { label: 'Plate Rating', value: battery.plate_rating || 'N/A' }
    ];

    details.forEach(detail => {
        const card = document.createElement('div');
        card.className = detail.highlight ? 'detail-card highlight' : 'detail-card';
        card.innerHTML = `<h3>${detail.label}</h3><p>${detail.value}</p>`;
        batteryDetailsDiv.appendChild(card);
    });

    const quoteCard = document.createElement('div');
    quoteCard.className = 'detail-card';
    quoteCard.innerHTML = `
        <h3>Solicitar Cotización</h3>
        <a href="${QUOTE_URL}" target="_blank" rel="noopener" class="pdf-link">⚡ Cotizar Batería</a>
    `;
    batteryDetailsDiv.appendChild(quoteCard);

    resultsDiv.style.display = 'block';
    noResultsDiv.style.display = 'none';
}

function displayNoResults() {
    hideLoader();
    resultsDiv.style.display = 'none';
    noResultsDiv.style.display = 'block';
}

function showLoader() {
    loaderDiv.style.display = 'block';
    resultsDiv.style.display = 'none';
    noResultsDiv.style.display = 'none';
}
function hideLoader() { loaderDiv.style.display = 'none'; }
function hideResults() {
    resultsDiv.style.display = 'none';
    noResultsDiv.style.display = 'none';
}
