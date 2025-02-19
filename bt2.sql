
create database Bt2;
use Bt2;
-- 1. Bảng departments (Phòng ban)
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(255) NOT NULL
);

-- 2. Bảng employees (Nhân viên)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE
);

-- 3. Bảng attendance (Chấm công)
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    check_in_time DATETIME NOT NULL,
    check_out_time DATETIME,
    total_hours DECIMAL(5,2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- 4. Bảng salaries (Bảng lương)
CREATE TABLE salaries (
    employee_id INT PRIMARY KEY,
    base_salary DECIMAL(10,2) NOT NULL,
    bonus DECIMAL(10,2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

-- 5. Bảng salary_history (Lịch sử lương)
CREATE TABLE salary_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

delimiter //
create trigger before_insert_employee
before insert on employees
for each row
begin
    if new.email not like '%@company.com' then
        set new.email = concat(new.email, '@company.com');
    end if;
end;
//
delimiter ;

delimiter //
create trigger after_insert_employee
after insert on employees
for each row
begin
    insert into salaries (employee_id, base_salary, bonus)
    values (new.employee_id, 10000.00, 0.00);
end;
//
delimiter ;

delimiter //
create trigger after_delete_employee
after delete on employees
for each row
begin
    declare last_salary decimal(10,2);
    declare last_bonus decimal(10,2);

    select base_salary, bonus into last_salary, last_bonus
    from salaries where employee_id = old.employee_id;

    insert into salary_history (employee_id, old_salary, new_salary, reason)
    values (old.employee_id, last_salary, null, 'nhân viên bị xóa');

    delete from salaries where employee_id = old.employee_id;
end;
//
delimiter ;

delimiter //
create trigger before_update_attendance
before update on attendance
for each row
begin
    if new.check_out_time is not null then
        set new.total_hours = timestampdiff(hour, new.check_in_time, new.check_out_time);
    end if;
end;
//
delimiter ;

insert into departments (department_name) values 
('phòng nhân sự'),
('phòng kỹ thuật');

insert into employees (name, email, phone, hire_date, department_id)
values ('nguyễn văn a', 'nguyenvana', '0987654321', '2024-02-17', 1);

select * from employees;

insert into employees (name, email, phone, hire_date, department_id)
values ('trần thị b', 'tranthib@company.com', '0912345678', '2024-02-17', 2);

select * from salaries;

insert into attendance (employee_id, check_in_time)
values (1, '2024-02-17 08:00:00');

update attendance
set check_out_time = '2024-02-17 17:00:00'
where employee_id = 1;

select * from attendance;
