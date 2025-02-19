
create database Bt5;
use Bt1;
delimiter //
create trigger before_insert_check_payment
before insert on payments
for each row
begin
    declare total_order decimal(10,2);
    select total_amount into total_order
    from orders
    where order_id = new.order_id;
    if new.amount <> total_order then
        signal sqlstate '45000'
        set message_text = 'số tiền thanh toán không khớp với tổng đơn hàng!';
    end if;
end;
//
delimiter ;

create table order_logs (
    log_id int primary key auto_increment,
    order_id int not null,
    old_status enum('pending', 'completed', 'cancelled'),
    new_status enum('pending', 'completed', 'cancelled'),
    log_date timestamp default current_timestamp,
    foreign key (order_id) references orders(order_id) on delete cascade
);

delimiter //
create trigger after_update_order_status
after update on orders
for each row
begin
    if old.status <> new.status then
        insert into order_logs (order_id, old_status, new_status, log_date)
        values (new.order_id, old.status, new.status, now());
    end if;
end;
//
delimiter ;

delimiter //
create procedure sp_update_order_status_with_payment(
    in p_order_id int,
    in p_new_status enum('pending', 'completed', 'cancelled'),
    in p_payment_amount decimal(10,2),
    in p_payment_method varchar(50)
)
begin
    declare current_status enum('pending', 'completed', 'cancelled');
    declare total_order_amount decimal(10,2);
    start transaction;
    select status into current_status
    from orders
    where order_id = p_order_id;
    if current_status is null then
        rollback;
        signal sqlstate '45000'
        set message_text = 'đơn hàng không tồn tại!';
    end if;
    if current_status = p_new_status then
        rollback;
        signal sqlstate '45000'
        set message_text = 'đơn hàng đã có trạng thái này!';
    end if;
    if p_new_status = 'completed' then
        select total_amount into total_order_amount
        from orders
        where order_id = p_order_id;
        if p_payment_amount <> total_order_amount then
            rollback;
            signal sqlstate '45000'
            set message_text = 'số tiền thanh toán không khớp với tổng đơn hàng!';
        end if;
        insert into payments (order_id, payment_date, amount, payment_method, status)
        values (p_order_id, now(), p_payment_amount, p_payment_method, 'completed');
    end if;
    update orders
    set status = p_new_status
    where order_id = p_order_id;
    commit;
end;
//
delimiter ;

insert into orders (order_id, total_amount, status) values (1, 1000.00, 'pending');

call sp_update_order_status_with_payment(1, 'completed', 1000.00, 'credit card');

select * from order_logs;

drop trigger if exists before_insert_check_payment;
drop trigger if exists after_update_order_status;
drop procedure if exists sp_update_order_status_with_payment;
