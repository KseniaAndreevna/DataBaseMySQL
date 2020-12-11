/*1. Создать VIEW на основе запросов, которые вы сделали в ДЗ к уроку 3.
2. Создать функцию, которая найдет менеджера по имени и фамилии.
3. Создать триггер, который при добавлении нового сотрудника будет 
выплачивать ему вступительный бонус, занося запись об этом в таблицу salary.*/

/* 1 */

CREATE VIEW cities_full_info_v AS
select ct.*, r.title reg_title, c.title  city_title from _cities ct, _regions r, _countries c
 where ct.region_id = r.id 
and r.country_id = c.id;

CREATE VIEW mos_reg_v AS
select ct.*, r.title reg_title, c.title  city_title, r.id reg_id from _cities ct, _regions r, _countries c
 where ct.region_id = r.id 
and r.country_id = c.id
and r.id = 1053480 /*and r.title = 'Московская область'*/;

select * from cities_full_info_v;
select * from mos_reg_v;

CREATE VIEW avg_salary_v AS
select avg(salary), d.dept_name from departments d, salaries s, employees e, dept_emp de
where d.dept_no = de.dept_no and e.emp_no = de.emp_no and s.emp_no = e.emp_no group by d.dept_name;

CREATE VIEW max_salary_v AS
select max(salary), e.first_name, e.last_name, e.emp_no from salaries s, employees e
where s.emp_no = e.emp_no group by e.emp_no order by 1 desc;

CREATE VIEW max_emp_salary_v AS
select * from employees where emp_no = 
(SELECT emp_no FROM salaries GROUP BY emp_no order by max(salary)desc limit 1);

CREATE VIEW count_dept_emp_v AS
select count(e.emp_no), d.dept_name from departments d, employees e, dept_emp de
where d.dept_no = de.dept_no and e.emp_no = de.emp_no group by de.dept_no;

CREATE VIEW sum_dept_salary_v AS
select sum(salary), count(distinct e.emp_no), d.dept_name from departments d, salaries s, employees e, dept_emp de
where d.dept_no = de.dept_no and e.emp_no = de.emp_no and s.emp_no = e.emp_no group by d.dept_name;

select * from avg_salary_v;
select * from max_salary_v;
select * from max_emp_salary_v;
select * from count_dept_emp_v;
select * from sum_dept_salary_v;


/*2*/

CREATE DEFINER=`root`@`localhost` FUNCTION `get_manager_name`(
	f_last_name VARCHAR(50),
    f_first_name VARCHAR(50)
) RETURNS varchar(200) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
 DECLARE mng_name VARCHAR(200);
SELECT 
    CONCAT(e.first_name,
            ' ',
            e.last_name,
            ' №',
            CONVERT(e.emp_no, CHAR)) mng_name
INTO mng_name FROM
    employees e,
    dept_manager dm
WHERE
    e.emp_no = dm.emp_no
        AND e.last_name = f_last_name
        AND e.first_name = f_first_name;
	RETURN (mng_name);
END

SELECT GET_MANAGER_NAME("Pesch","Dung") as mng_name;


/*3*/

CREATE DEFINER=`root`@`localhost` TRIGGER `employees_AFTER_INSERT` AFTER INSERT ON `employees` FOR EACH ROW BEGIN
 insert into salaries (emp_no, salary, from_date, to_date)
 values (new.emp_no, 50000, current_date(), curdate());
END

insert into employees (emp_no, birth_date, first_name, last_name, gender, hire_date)
values(999999, curdate() ,'TEST1_FIRST_N','TEST1_LAST_N', 'M', curdate());

select * from employees where emp_no = 999999;
select * from salaries where emp_no = 999999;
