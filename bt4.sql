
create database Bt4;
use Bt2;
delimiter //
create procedure IncreaseSalary(
    in emp_id int,
    in new_salary decimal(10,2),
    in reason text
)
begin
    declare old_salary decimal(10,2);

    start transaction;

    select salary into old_salary
    from salaries
    where employee_id = emp_id;

    if old_salary is null then
        rollback;
        signal sqlstate '45000'
        set message_text = 'Nhân viên không tồn tại!';
    else
        insert into salary_history (employee_id, old_salary, new_salary, reason)
        values (emp_id, old_salary, new_salary, reason);

        update salaries
        set salary = new_salary
        where employee_id = emp_id;

        commit;
    end if;
end;
//
delimiter ;

call IncreaseSalary(1, 5000.00, 'Tăng lương định kỳ');

delimiter //
create procedure DeleteEmployee(in emp_id int)
begin
    declare emp_exists int;

    start transaction;

    select count(*) into emp_exists
    from employees
    where id = emp_id;

    if emp_exists = 0 then
        rollback;
        signal sqlstate '45000'
        set message_text = 'Nhân viên không tồn tại!';
    else
        insert into salary_history (employee_id, old_salary, new_salary, reason)
        select employee_id, salary, 0, 'Xóa nhân viên'
        from salaries
        where employee_id = emp_id;

        delete from salaries where employee_id = emp_id;
        delete from employees where id = emp_id;

        commit;
    end if;
end;
//
delimiter ;

call DeleteEmployee(2);
