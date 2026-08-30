# Pandas Data Cleansing Cheat Sheet

## 1. สำรวจข้อมูลเบื้องต้น (Explore)

```python
import pandas as pd

df.head()              # ดู 5 แถวแรก
df.tail()               # ดู 5 แถวสุดท้าย
df.shape                 # (จำนวนแถว, จำนวนคอลัมน์)
df.info()                # ชนิดข้อมูล + non-null count
df.describe()             # สถิติเบื้องต้น (mean, std, min, max ฯลฯ)
df.dtypes                 # ชนิดข้อมูลแต่ละคอลัมน์
df.columns                # รายชื่อคอลัมน์
df.nunique()               # จำนวนค่าที่ไม่ซ้ำในแต่ละคอลัมน์
df['col'].value_counts()    # นับความถี่ของแต่ละค่า
```

## 2. ตรวจสอบและจัดการ Missing Values

```python
df.isnull().sum()                     # นับจำนวน null ต่อคอลัมน์
df.isnull().mean() * 100                # % ของ null ต่อคอลัมน์
df.isnull().sum().sort_values(ascending=False)  # เรียงจากมากไปน้อย

# ลบ
df.dropna()                            # ลบแถวที่มี null
df.dropna(axis=1)                       # ลบคอลัมน์ที่มี null
df.dropna(subset=['col1', 'col2'])       # ลบเฉพาะถ้า col ที่ระบุเป็น null
df.dropna(thresh=3)                      # เก็บแถวที่มีค่าไม่ null อย่างน้อย 3 ค่า

# เติมค่า
df['col'].fillna(0)                      # เติมด้วยค่าคงที่
df['col'].fillna(df['col'].mean())         # เติมด้วยค่าเฉลี่ย
df['col'].fillna(df['col'].median())        # เติมด้วยค่ามัธยฐาน
df['col'].fillna(df['col'].mode()[0])        # เติมด้วยฐานนิยม
df['col'].fillna(method='ffill')              # เติมด้วยค่าก่อนหน้า (forward fill)
df['col'].fillna(method='bfill')              # เติมด้วยค่าถัดไป (backward fill)
df.fillna({'col1': 0, 'col2': 'unknown'})      # เติมหลายคอลัมน์พร้อมกัน
df['col'].interpolate()                          # เติมแบบ interpolation
```

## 3. จัดการข้อมูลซ้ำ (Duplicates)

```python
df.duplicated().sum()                 # นับจำนวนแถวที่ซ้ำ
df[df.duplicated()]                    # ดูแถวที่ซ้ำ
df.drop_duplicates()                    # ลบแถวซ้ำ (เก็บตัวแรก)
df.drop_duplicates(subset=['col'])       # ลบซ้ำโดยดูแค่บางคอลัมน์
df.drop_duplicates(keep='last')           # เก็บตัวสุดท้ายแทน
```

## 4. แก้ไขชนิดข้อมูล (Data Types)

```python
df['col'] = df['col'].astype(int)
df['col'] = df['col'].astype(float)
df['col'] = df['col'].astype(str)
df['col'] = df['col'].astype('category')

df['date_col'] = pd.to_datetime(df['date_col'], errors='coerce')
df['num_col'] = pd.to_numeric(df['num_col'], errors='coerce')
```
> `errors='coerce'` จะแปลงค่าที่แปลงไม่ได้ให้เป็น NaN แทนที่จะ error

## 5. จัดการข้อความ (String Cleaning)

```python
df['col'] = df['col'].str.strip()          # ตัดช่องว่างหน้า-หลัง
df['col'] = df['col'].str.lower()           # ตัวพิมพ์เล็ก
df['col'] = df['col'].str.upper()           # ตัวพิมพ์ใหญ่
df['col'] = df['col'].str.title()            # ตัวพิมพ์ใหญ่ต้นคำ
df['col'] = df['col'].str.replace(' ', '_')   # แทนที่ตัวอักษร
df['col'] = df['col'].str.replace(r'[^\w\s]', '', regex=True)  # ลบอักขระพิเศษ
df['col'] = df['col'].str.extract(r'(\d+)')    # ดึงตัวเลขออกมาด้วย regex
df['col'].str.contains('pattern', na=False)     # เช็คว่ามี pattern หรือไม่
df['col'].str.split(',').str[0]                  # แยกข้อความแล้วเอาส่วนแรก
```

## 6. จัดการ Outliers

```python
# วิธี IQR
Q1 = df['col'].quantile(0.25)
Q3 = df['col'].quantile(0.75)
IQR = Q3 - Q1
lower = Q1 - 1.5 * IQR
upper = Q3 + 1.5 * IQR
df_clean = df[(df['col'] >= lower) & (df['col'] <= upper)]

# วิธี Z-score
from scipy import stats
df['zscore'] = stats.zscore(df['col'])
df_clean = df[df['zscore'].abs() <= 3]

# Clip ค่าที่เกินขอบเขต แทนการลบทิ้ง
df['col'] = df['col'].clip(lower=lower, upper=upper)
```

## 7. เปลี่ยนชื่อ / จัดระเบียบคอลัมน์

```python
df.rename(columns={'old_name': 'new_name'}, inplace=True)
df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_')  # standardize ชื่อคอลัมน์ทั้งหมด
df.drop(columns=['col1', 'col2'], inplace=True)
df.reset_index(drop=True, inplace=True)
```

## 8. Mapping / Replace ค่า

```python
df['col'] = df['col'].replace({'old_val': 'new_val'})
df['col'] = df['col'].map({'Y': 1, 'N': 0})
df['category'] = pd.cut(df['num_col'], bins=[0, 18, 60, 100], labels=['เด็ก', 'ผู้ใหญ่', 'สูงอายุ'])
```

## 9. กรองข้อมูลผิดปกติ (Validation)

```python
df[df['age'] < 0]                       # หาแถวที่ผิดปกติ เช่น อายุติดลบ
df = df[df['age'].between(0, 120)]        # เก็บเฉพาะช่วงที่สมเหตุสมผล
df[~df['email'].str.contains('@', na=False)]  # หาอีเมลที่ไม่ถูกต้อง
```

## 10. Apply / Lambda สำหรับ Custom Cleaning

```python
df['col'] = df['col'].apply(lambda x: x.strip() if isinstance(x, str) else x)
df['new_col'] = df.apply(lambda row: row['a'] + row['b'], axis=1)
```

## 11. เวิร์กโฟลว์แนะนำ (Workflow สรุป)

```python
df = pd.read_csv('data.csv')

# 1) สำรวจ
df.info()
df.isnull().sum()

# 2) ลบซ้ำ
df.drop_duplicates(inplace=True)

# 3) มาตรฐานชื่อคอลัมน์
df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_')

# 4) แก้ชนิดข้อมูล
df['date'] = pd.to_datetime(df['date'], errors='coerce')

# 5) จัดการ missing values
df['amount'] = df['amount'].fillna(df['amount'].median())

# 6) จัดการข้อความ
df['name'] = df['name'].str.strip().str.title()

# 7) จัดการ outliers
df = df[df['amount'].between(0, df['amount'].quantile(0.99))]

# 8) ตรวจสอบผลลัพธ์
df.info()
df.describe()
```

---
**Tip:** ใช้ `df.copy()` ก่อนเริ่ม clean เสมอ เพื่อไม่ให้กระทบ DataFrame ต้นฉบับ เช่น `df_clean = df.copy()`
