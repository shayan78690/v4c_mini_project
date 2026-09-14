# Quick Setup & Test Checklist

Run these commands in order. Check off each ✅ as you go.

---

## SETUP

### [ ] 1. Activate virtual environment
```bash
python -m venv venv
source venv/bin/activate        # Mac/Linux
# OR
venv\Scripts\activate           # Windows
```

### [ ] 2. Install packages
```bash
pip install -r requirements.txt
```

### [ ] 3. Create .env file
```bash
cp .env.example .env
# Edit .env and add your MySQL password
```

### [ ] 4. Run SQL in MySQL Workbench (in order)
```
sql/01_oltp_ddl.sql
sql/02_olap_ddl.sql
sql/03_etl_procedures.sql
```

### [ ] 5. Synthesize data
```bash
python scripts/synthesizer.py
```

### [ ] 6. Load data into MySQL
```bash
python scripts/data_loader.py
```

### [ ] 7. Launch the app
```bash
streamlit run streamlit_app/app.py
```

---

## TESTING (run all at once)

```bash
python -c "
print('=== TEST SUITE ===')

# T1: Packages
import pandas, faker, mysql.connector, streamlit, plotly
print('T1 ✅ All packages installed')

# T2: Singleton
from backend.db_manager import DatabaseConnection
assert DatabaseConnection() is DatabaseConnection()
print('T2 ✅ Singleton pattern works')

# T3: Models
from backend.models import Employee, Department, Project, Review
from datetime import date
emp = Employee('A','B','a@b.com',date(2024,1,1),1,'Analyst',5000,age=25,job_level=2)
assert emp.validate() == []
assert emp.full_name == 'A B'
assert emp.annual_income == 60000
bad = Employee('','','bad',date(2024,1,1),1,'X',-1,age=200,job_level=9)
assert len(bad.validate()) == 5
r = Review(1,date(2024,1,1),2024,4,review_quarter=2)
assert r.rating_label == 'Outstanding'
print('T3 ✅ All model validations pass')

# T4: Synthesizer output
import pandas as pd, os
if os.path.exists('data/employees_synthesized.csv'):
    df1 = pd.read_csv('data/employees_synthesized.csv')
    df2 = pd.read_csv('data/employees_historical.csv')
    assert len(df1) >= 100000
    assert df2['IsCurrent'].sum() == 5000
    print(f'T4 ✅ Synthesizer: {len(df1):,} rows | SCD2: {len(df2):,} rows')
else:
    print('T4 ⚠️  Run synthesizer.py first')

# T5: Streamlit pages syntax
import ast
pages = ['streamlit_app/pages/home.py','streamlit_app/pages/onboard.py',
         'streamlit_app/pages/projects.py','streamlit_app/pages/reviews.py',
         'streamlit_app/pages/dashboard.py']
for p in pages:
    with open(p) as f: src = f.read()
    ast.parse(src)
    assert 'def render():' in src
print('T5 ✅ All Streamlit pages syntax OK')

# T6: SQL files
import re
checks = {
    'sql/01_oltp_ddl.sql':   ('CREATE TABLE', 6),
    'sql/02_olap_ddl.sql':   ('CREATE TABLE', 5),
    'sql/03_etl_procedures.sql': ('CREATE PROCEDURE', 5),
}
for f,(kw,n) in checks.items():
    with open(f) as fh: sql = fh.read()
    found = len(re.findall(kw, sql, re.I))
    assert found >= n, f'{f}: expected {n} {kw}, found {found}'
print('T6 ✅ All SQL files verified')

# T7: DB connection (needs MySQL running)
try:
    from dotenv import load_dotenv; load_dotenv()
    db = DatabaseConnection()
    db.connect('hr_oltp')
    rows = db.fetch_all('SELECT COUNT(*) AS cnt FROM Employees')
    print(f'T7 ✅ DB connected | Employees in DB: {rows[0][\"cnt\"]:,}')
    db.disconnect()
except Exception as e:
    print(f'T7 ⚠️  DB not reachable yet ({e}) — run data_loader.py first')

print()
print('=== ALL TESTS COMPLETE ===')
"
```

---

## APP PAGES CHECKLIST

After launching `streamlit run streamlit_app/app.py`:

| Page | What to check |
|---|---|
| 🏠 Home | Metric cards show, architecture table loads |
| ➕ Onboard Employee | Fill form → submit → success message + SCD2 note |
| 📁 Projects | Create project → assign employee → view project list |
| 📝 Performance Review | Submit review → see trend chart for that employee |
| 📊 Dashboard | All 5 charts load: KPIs, YoY, Top Performers, Attrition Risk, Salary |

---

## VERIFY SCD TYPE 2 WORKS

1. Note an employee ID (e.g. 5)
2. Go to **Onboard → Update Department** tab
3. Change their department → click submit
4. Go to **Dashboard → Employee Career History**
5. Enter employee ID 5 → click View
6. Should see 2 rows: old dept (is_current=0) + new dept (is_current=1)

