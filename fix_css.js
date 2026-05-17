const fs = require('fs');
const path = 'c:\\Data\\Work\\MLM\\ecommerce-mlm\\assets\\css\\style.css';
let content = fs.readFileSync(path, 'utf8');

// Find index of the final correct bracket from .btn-trigger-verify:hover { ... }
let key = '.btn-trigger-verify:hover {';
let idx = content.lastIndexOf(key);
if (idx === -1) {
    console.error("Could not find key");
    process.exit(1);
}

// Cut everything before the corrupted append
let endIdx = content.indexOf('}', idx);
let cleanBase = content.substring(0, endIdx + 1);

let newCss = `

/* Orders Table Styles */
.orders-table-container { 
    width: 100%; 
    overflow-x: auto; 
    border-radius: 12px; 
    margin-top: 10px;
}

.orders-table { 
    width: 100%; 
    border-collapse: separate; 
    border-spacing: 0; 
}

.orders-table th { 
    background: #f8fafc; 
    padding: 15px; 
    text-align: left; 
    color:#888888; 
    font-weight: 600; 
    font-size: 0.85rem; 
    text-transform: uppercase; 
    letter-spacing: 1px; 
    border-bottom: 1px solid #f1f5f9; 
}

.orders-table td { 
    padding: 18px 15px; 
    border-bottom: 1px solid #f1f5f9; 
    vertical-align: middle; 
    font-size: 0.95rem; 
    color: #334155; 
}

.orders-table tr:hover td { 
    background: #f8fafc; 
}

.order-id { 
    font-weight: 700; 
    color: #1e293b; 
}

.order-date { 
    font-size: 0.85rem; 
    color:#888888; 
}

.order-status-badge { 
    display: inline-flex; 
    align-items: center; 
    gap: 6px; 
    padding: 6px 12px; 
    border-radius: 50px; 
    font-weight: 600; 
    font-size: 0.75rem; 
    text-transform: uppercase; 
}

.status-pending { background: #fffbeb; color: #d97706; }
.status-completed { background: #ecfdf5; color: #059669; }
.status-cancelled { background: #fef2f2; color: #dc2626; }
.status-shipped { background: #eff6ff; color: #2563eb; }

.btn-view-order { 
    display: inline-flex; 
    align-items: center; 
    gap: 5px; 
    padding: 8px 16px; 
    background: #ffffff; 
    border: 1px solid #e2e8f0; 
    border-radius: 8px; 
    color: #475569; 
    text-decoration: none; 
    font-size: 0.85rem; 
    font-weight: 600; 
    transition: all 0.2s ease; 
}

.btn-view-order:hover { 
    background: #111827; 
    color: #fff; 
    border-color: #111827; 
    box-shadow: 0 4px 12px rgba(17,24,39,0.15); 
}`;

fs.writeFileSync(path, cleanBase + newCss, 'utf8');
console.log("CSS successfully cleaned and replaced!");
