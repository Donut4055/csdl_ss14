
create database Bt6;
use Bt4;
delimiter //
create trigger before_update_check_phone
before update on employees
for each row
begin
    if length(new.phone) <> 10 then
        signal sqlstate '45000'
        set message_text = 'số điện thoại phải có đúng 10 chữ số!';
    end if;
end;
//
delimiter ;

create table notifications (
    notification_id int primary key auto_increment,
    employee_id int not null,
    message text not null,
    created_at timestamp default current_timestamp,
    foreign key (employee_id) references employees(employee_id) on delete cascade
);

delimiter //
create trigger after_insert_employee_notification
after insert on employees
for each row
begin
    insert into notifications (employee_id, message)
    values (new.employee_id, 'chào mừng');
end;
//
delimiter ;

delimiter //
create procedure AddNewEmployeeWithPhone(
    in emp_name varchar(255),
    in emp_email varchar(255),
    in emp_phone varchar(20),
    in emp_hire_date date,
    in emp_department_id int
)
begin
    declare emp_id int;
    start transaction;
    if length(emp_phone) <> 10 then
        rollback;
        signal sqlstate '45000'
        set message_text = 'số điện thoại phải có đúng 10 chữ số!';
    end if;
    insert into employees (name, email, phone, hire_date, department_id)
    values (emp_name, emp_email, emp_phone, emp_hire_date, emp_department_id);
    select last_insert_id() into emp_id;
    commit;
end;
//
delimiter ;

insert into employees (name, email, phone, hire_date, department_id) 
values ('Nguyen Van A', 'nguyenvana@example.com', '0123456789', '2024-02-17', 1);

call AddNewEmployeeWithPhone('Tran Thi B', 'tranthib@example.com', '0987654321', '2024-02-17', 2);

select * from notifications;

drop trigger if exists before_update_check_phone;
drop trigger if exists after_insert_employee_notification;
drop procedure if exists AddNewEmployeeWithPhone;
