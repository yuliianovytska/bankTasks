
-- 1. +Вибрати усіх клієнтів, чиє ім'я має менше ніж 6 символів.

select * from client where length(FirstName)<6;

-- 2. +Вибрати львівські відділення банку.+

select * from department where DepartmentCity = 'Lviv';

-- 3. +Вибрати клієнтів з вищою освітою та посортувати по прізвищу.

select * from client where Education = 'high'
order by LastName;

-- 4. +Виконати сортування у зворотньому порядку над таблицею Заявка і вивести 5 останніх елементів.

select * from application
order by idApplication desc
limit 5;

-- 5. +Вивести усіх клієнтів, чиє прізвище закінчується на OV чи OVA.

select * from client where LastName like '%ov' or LastName like '%ova';

-- 6. +Вивести клієнтів банку, які обслуговуються київськими відділеннями.

select * from client,department
where client.Department_idDepartment = department.idDepartment
and department.DepartmentCity = 'Kyiv';

-- 7. +Вивести імена клієнтів та їхні номера телефону, погрупувавши їх за іменами.

select FirstName, LastName, Passport from client
order by FirstName;

-- 8. +Вивести дані про клієнтів, які мають кредит більше ніж на 5000 тисяч гривень.

select * from client, application
where client.idClient = application.Client_idClient
and Sum > 5000;

-- 9. +Порахувати кількість клієнтів усіх відділень та лише львівських відділень.

select count(idClient) from client,department
where client.Department_idDepartment = department.idDepartment
union
select count(idClient) from client,department
where client.Department_idDepartment = department.idDepartment
and DepartmentCity = 'Lviv';

-- 10. Знайти кредити, які мають найбільшу суму для кожного клієнта окремо.

select max(Sum),FirstName,LastName from client,application
where client.idClient = application.Client_idClient
group by idClient;

-- 11. Визначити кількість заявок на крдеит для кожного клієнта.

select count(idApplication),FirstName,LastName from client,application
where client.idClient = application.Client_idClient
group by idClient;

-- 12. Визначити найбільший та найменший кредити.

select max(Sum) from application
union
select min(Sum) from application;

-- 13. Порахувати кількість кредитів для клієнтів,які мають вищу освіту.

select count(application.idApplication),FirstName,LastName,Education from client,application
where idClient = Client_idClient
and Education = 'high'
group by idClient;

-- 14. Вивести дані про клієнта, в якого середня сума кредитів найвища.

select avg(Sum) as avg,FirstName,LastName from client,application
where idClient = Client_idClient
group by idClient
order by avg desc
limit 1;

-- 15. Вивести відділення, яке видало в кредити найбільше грошей

select sum(Sum) as summ, DepartmentCity from department,client,application
where client.Department_idDepartment = department.idDepartment
and client.idClient = application.Client_idClient
group by idDepartment
order by summ desc
limit 1;

-- 16. Вивести відділення, яке видало найбільший кредит.

select max(Sum) as maxcredit, DepartmentCity from department,client,application
group by idDepartment
order by maxcredit desc
limit 1;

-- 17. Усім клієнтам, які мають вищу освіту, встановити усі їхні кредити у розмірі 6000 грн.

update client, application
set sum = 6000
where idClient = Client_idClient
and Education = 'high';

-- 18. Усіх клієнтів київських відділень пересилити до Києва.

update client, department
set City = 'Kyiv'
where Department_idDepartment = idDepartment
and DepartmentCity = 'Kyiv';

-- 19. Видалити усі кредити, які є повернені.

delete from application
where CreditState = 'Returned';

-- 20. Видалити кредити клієнтів, в яких друга літера прізвища є голосною.

delete application from application,client
where idClient = Client_idClient
and client.idClient in( select * from (select client.idClient from client where substr(client.LastName,2,1) in ('a','e','i','o','u','y')) as t);


-- Знайти львівські відділення, які видали кредитів на загальну суму більше ніж 5000

select * from client,department,application
where client.Department_idDepartment = department.idDepartment
and application.Client_idClient = client.idClient
and DepartmentCity = 'Lviv'
and Sum > 5000;

-- Знайти клієнтів, які повністю погасили кредити на суму більше ніж 5000

select FirstName, LastName, Sum, CreditState from client,application
where client.idClient = application.Client_idClient
and application.CreditState = 'Returned'
and Sum > 5000;

-- /* Знайти максимальний неповернений кредит.*/

select application.idApplication , application.Sum from application
where Sum = (select max(Sum) from application)
and CreditState = 'Not returned';

-- /*Знайти клієнта, сума кредиту якого найменша*/

select client.FirstName,client.LastName, application.Sum
from client, application
where client.idClient=application.Client_idClient
and Sum = (select min(Sum) from application);

-- /*Знайти кредити, сума яких більша за середнє значення усіх кредитів*/

select application.idApplication, application.Sum from application
where Sum > (select avg(Sum) from application);

-- /*Знайти клієнтів, які є з того самого міста, що і клієнт, який взяв найбільшу кількість кредитів*/

select * from client,application
where client.idClient = application.Client_idClient
and client.City like (
select City from client,application
where client.idClient = application.Client_idClient
group by idClient
order by count(application.idApplication) desc
limit 1)
group by idClient;

-- #місто чувака який набрав найбільше кредитів

select * from client,application
where client.idClient = application.Client_idClient
and client.City like (
select City from client,application
where client.idClient = application.Client_idClient
group by idClient
order by Sum = max(application.Sum) desc
limit 1)
group by idClient;
