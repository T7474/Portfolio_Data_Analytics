# SQL Cheat Sheet (พื้นฐาน → Subquery, CTE, Window Function)

## 1. พื้นฐานการดึงข้อมูล (SELECT)

```sql
-- ดึงทุกคอลัมน์
SELECT * FROM employees;

-- ดึงเฉพาะคอลัมน์ที่ต้องการ
SELECT first_name, salary FROM employees;

-- ตั้งชื่อคอลัมน์ใหม่ (Alias)
SELECT first_name AS name, salary AS income FROM employees;

-- ไม่เอาค่าซ้ำ
SELECT DISTINCT department FROM employees;
```

## 2. การกรองข้อมูล (WHERE)

```sql
SELECT * FROM employees WHERE department = 'Sales';

-- ตัวดำเนินการเปรียบเทียบ
=, !=, <>, >, <, >=, <=

-- ตรรกะ
WHERE salary > 30000 AND department = 'IT';
WHERE department = 'IT' OR department = 'HR';
WHERE NOT department = 'IT';

-- ช่วงค่า / กลุ่มค่า
WHERE salary BETWEEN 20000 AND 50000;
WHERE department IN ('IT', 'HR', 'Sales');

-- ค่าว่าง (NULL)
WHERE manager_id IS NULL;
WHERE manager_id IS NOT NULL;

-- รูปแบบข้อความ
WHERE name LIKE 'A%';    -- ขึ้นต้นด้วย A
WHERE name LIKE '%son';  -- ลงท้ายด้วย son
WHERE name LIKE '_om%';  -- ตัวที่ 2-3 เป็น om
```

## 3. การเรียงลำดับและจำกัดผลลัพธ์

```sql
SELECT * FROM employees
ORDER BY salary DESC, first_name ASC;

SELECT * FROM employees
LIMIT 10;          -- MySQL/PostgreSQL

SELECT TOP 10 * FROM employees;  -- SQL Server
```

## 4. ฟังก์ชันรวม (Aggregate Functions)

```sql
SELECT COUNT(*) FROM employees;
SELECT SUM(salary) FROM employees;
SELECT AVG(salary) FROM employees;
SELECT MAX(salary), MIN(salary) FROM employees;
```

## 5. การจัดกลุ่มข้อมูล (GROUP BY / HAVING)

```sql
-- รวมข้อมูลตามกลุ่ม
SELECT department, COUNT(*) AS total_employees
FROM employees
GROUP BY department;

-- กรองหลัง GROUP BY (WHERE ใช้กรองก่อนรวมกลุ่มไม่ได้)
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 30000;
```

**ลำดับการทำงานจริงของ SQL:**
`FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT`

## 6. การรวมตาราง (JOIN)

```sql
-- INNER JOIN: เอาเฉพาะที่ตรงกันทั้งสองฝั่ง
SELECT e.first_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.id;

-- LEFT JOIN: เอาทุกแถวจากตารางซ้าย แม้ไม่มีคู่ตรงกัน
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id;

-- RIGHT JOIN: เอาทุกแถวจากตารางขวา
SELECT e.first_name, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.id;

-- FULL OUTER JOIN: เอาทุกแถวทั้งสองฝั่ง
SELECT e.first_name, d.department_name
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.id;

-- SELF JOIN: join ตารางกับตัวเอง
SELECT a.first_name AS employee, b.first_name AS manager
FROM employees a
LEFT JOIN employees b ON a.manager_id = b.id;

-- CROSS JOIN: จับคู่ทุกแถวกับทุกแถว
SELECT * FROM sizes CROSS JOIN colors;
```

## 7. UNION / INTERSECT / EXCEPT

```sql
-- รวมผลลัพธ์ (ตัดซ้ำ)
SELECT name FROM customers
UNION
SELECT name FROM suppliers;

-- รวมผลลัพธ์ (ไม่ตัดซ้ำ)
SELECT name FROM customers
UNION ALL
SELECT name FROM suppliers;

-- มีเฉพาะที่ซ้ำกันทั้งสองฝั่ง (PostgreSQL/SQL Server)
SELECT name FROM customers INTERSECT SELECT name FROM suppliers;

-- มีในฝั่งแรกแต่ไม่มีในฝั่งสอง
SELECT name FROM customers EXCEPT SELECT name FROM suppliers;
```

## 8. Subquery (Query ซ้อน Query)

```sql
-- Subquery ใน WHERE
SELECT first_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Subquery กับ IN
SELECT first_name
FROM employees
WHERE department_id IN (
    SELECT id FROM departments WHERE location = 'Bangkok'
);

-- Subquery ใน FROM (ต้องตั้งชื่อ alias เสมอ)
SELECT dept_avg.department_id, dept_avg.avg_salary
FROM (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) AS dept_avg
WHERE dept_avg.avg_salary > 30000;

-- Correlated Subquery (subquery อ้างอิงตารางหลัก)
SELECT e.first_name, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);

-- EXISTS / NOT EXISTS
SELECT d.department_name
FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department_id = d.id
);
```

## 9. CTE — Common Table Expression (WITH)

```sql
-- CTE พื้นฐาน: ตั้งชื่อผลลัพธ์ชั่วคราวไว้ใช้ต่อ อ่านง่ายกว่า subquery ซ้อนลึกๆ
WITH dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.first_name, e.salary, d.avg_salary
FROM employees e
JOIN dept_avg d ON e.department_id = d.department_id
WHERE e.salary > d.avg_salary;

-- หลาย CTE ต่อกัน
WITH high_earners AS (
    SELECT * FROM employees WHERE salary > 50000
),
by_dept AS (
    SELECT department_id, COUNT(*) AS cnt
    FROM high_earners
    GROUP BY department_id
)
SELECT * FROM by_dept;

-- Recursive CTE: ใช้ทำโครงสร้างต้นไม้/ลำดับชั้น เช่น org chart
WITH RECURSIVE org_chart AS (
    -- Anchor: จุดเริ่มต้น (คนที่ไม่มีหัวหน้า)
    SELECT id, first_name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive part: หาลูกทีมของแต่ละคนถัดไปเรื่อยๆ
    SELECT e.id, e.first_name, e.manager_id, oc.level + 1
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.id
)
SELECT * FROM org_chart ORDER BY level;
```

## 10. Window Functions

**หลักการ:** คำนวณข้ามหลายแถว แต่ยังคง **แสดงทุกแถว** (ต่างจาก GROUP BY ที่ยุบแถว)

```sql
-- โครงสร้างทั่วไป
function_name() OVER (
    PARTITION BY column   -- แบ่งกลุ่ม (คล้าย GROUP BY แต่ไม่ยุบแถว)
    ORDER BY column        -- เรียงลำดับภายในกลุ่ม
    ROWS/RANGE frame       -- กำหนดขอบเขตแถวที่คำนวณ (optional)
)
```

### 10.1 Ranking Functions

```sql
SELECT
    first_name,
    department_id,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS row_num,
    RANK()       OVER (PARTITION BY department_id ORDER BY salary DESC) AS rank_num,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dense_rank_num,
    NTILE(4)     OVER (PARTITION BY department_id ORDER BY salary DESC) AS quartile
FROM employees;
```
- `ROW_NUMBER()` → เลขเรียงไม่ซ้ำ (1,2,3,4...)
- `RANK()` → อันดับเท่ากันได้ แต่เว้นเลขที่ข้าม (1,2,2,4...)
- `DENSE_RANK()` → อันดับเท่ากันได้ ไม่เว้นเลข (1,2,2,3...)
- `NTILE(n)` → แบ่งเป็น n กลุ่มเท่าๆ กัน

### 10.2 Aggregate เป็น Window Function

```sql
SELECT
    first_name,
    department_id,
    salary,
    SUM(salary)   OVER (PARTITION BY department_id) AS dept_total,
    AVG(salary)   OVER (PARTITION BY department_id) AS dept_avg,
    COUNT(*)      OVER (PARTITION BY department_id) AS dept_count,
    salary - AVG(salary) OVER (PARTITION BY department_id) AS diff_from_avg
FROM employees;
```

### 10.3 LAG / LEAD (ดูแถวก่อนหน้า/ถัดไป)

```sql
SELECT
    order_date,
    revenue,
    LAG(revenue, 1)  OVER (ORDER BY order_date) AS prev_revenue,
    LEAD(revenue, 1) OVER (ORDER BY order_date) AS next_revenue,
    revenue - LAG(revenue, 1) OVER (ORDER BY order_date) AS revenue_change
FROM daily_sales;
```

### 10.4 FIRST_VALUE / LAST_VALUE

```sql
SELECT
    first_name,
    department_id,
    salary,
    FIRST_VALUE(first_name) OVER (
        PARTITION BY department_id ORDER BY salary DESC
    ) AS top_earner_in_dept
FROM employees;
```

### 10.5 Running Total / Moving Average (ใช้ ROWS)

```sql
-- ยอดสะสม (Running Total)
SELECT
    order_date,
    revenue,
    SUM(revenue) OVER (ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM daily_sales;

-- ค่าเฉลี่ยเคลื่อนที่ 7 วัน (Moving Average)
SELECT
    order_date,
    revenue,
    AVG(revenue) OVER (ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_7d
FROM daily_sales;
```

## 11. การแก้ไขข้อมูล (INSERT / UPDATE / DELETE)

```sql
-- เพิ่มข้อมูล
INSERT INTO employees (first_name, department_id, salary)
VALUES ('Somchai', 3, 35000);

-- แก้ไขข้อมูล
UPDATE employees
SET salary = salary * 1.1
WHERE department_id = 3;

-- ลบข้อมูล
DELETE FROM employees
WHERE id = 25;
```

## 12. CASE WHEN (เงื่อนไข)

```sql
SELECT
    first_name,
    salary,
    CASE
        WHEN salary >= 50000 THEN 'High'
        WHEN salary >= 30000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_level
FROM employees;
```

## 13. ลำดับความสำคัญที่ควรจำ

| หัวข้อ | ใช้เมื่อไหร่ |
|---|---|
| **JOIN** | ต้องการรวมข้อมูลจากหลายตาราง |
| **Subquery** | ต้องการผลลัพธ์ของ query หนึ่งไปใช้ในอีก query (ครั้งเดียว, ไม่ reuse) |
| **CTE** | logic ซับซ้อน ต้องการอ่านง่าย หรือใช้ผลลัพธ์เดิมซ้ำหลายที่ หรือทำ recursive |
| **Window Function** | ต้องการคำนวณข้ามแถว (อันดับ, สะสม, เทียบก่อนหน้า) แต่ยังโชว์ทุกแถว |
| **GROUP BY** | ต้องการยุบข้อมูลเป็นสรุปตามกลุ่ม |

## ลำดับการทำงานของ SQL Query (Execution Order)

```
1. FROM / JOIN
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT (รวมถึง Window Functions)
6. ORDER BY
7. LIMIT / OFFSET
```
