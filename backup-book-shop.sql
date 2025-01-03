PGDMP                       |            BookShop    17.0    17.0 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            �           1262    40995    BookShop    DATABASE     ~   CREATE DATABASE "BookShop" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Russian_Russia.1251';
    DROP DATABASE "BookShop";
                     postgres    false                       1255    41209 �   add_user(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)    FUNCTION       CREATE FUNCTION public.add_user(first_name character varying, last_name character varying, phone_number character varying, password character varying, v_address character varying, v_city character varying, v_country character varying, v_postal_code character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    address_id int;
begin
 
    select id into address_id
    from address
    where address = v_address
      and city = v_city
      and country = v_country
      and postal_code = v_postal_code;

   
    if address_id is null then
        insert into address(address, city, country, postal_code)
        values (v_address, v_city, v_country, v_postal_code)
        returning id into address_id;
    end if;

    begin
        insert into users(first_name, last_name, address_id, phone_number, password)
        values (first_name, last_name, address_id, phone_number, password);
    exception when unique_violation then
        return 'Bu telefon allaqachon mavjud';
    end;

    return 'User muvofaqiyatli qo`shildi';
end;
$$;
   DROP FUNCTION public.add_user(first_name character varying, last_name character varying, phone_number character varying, password character varying, v_address character varying, v_city character varying, v_country character varying, v_postal_code character varying);
       public               postgres    false                       1255    41215    add_user_role(integer, integer)    FUNCTION     �  CREATE FUNCTION public.add_user_role(user_id_param integer, role_id_param integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    if not exists (select 1 from role where id = role_id_param) then
        raise exception 'Rol id % rollar jadvalida mavjud emas', role_id_param;
    end if;
    insert into user_role (user_id, role_id)
    values (user_id_param, role_id_param);
end;
$$;
 R   DROP FUNCTION public.add_user_role(user_id_param integer, role_id_param integer);
       public               postgres    false                       1255    41211 �   add_user_with_address(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.add_user_with_address(address character varying, city character varying, country character varying, postal_code character varying, first_name character varying, last_name character varying, phone_number character varying, password character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    new_address_id int;
begin

    insert into address (address, city, country, postal_code)
    values (address, city, country, postal_code)
    returning id into new_address_id;

  
    insert into users (first_name, last_name, address_id, phone_number, password)
    values (first_name, last_name, new_address_id, phone_number, password);
end;
$$;
   DROP FUNCTION public.add_user_with_address(address character varying, city character varying, country character varying, postal_code character varying, first_name character varying, last_name character varying, phone_number character varying, password character varying);
       public               postgres    false                       1255    41225    best_seller()    FUNCTION     �  CREATE FUNCTION public.best_seller() RETURNS TABLE(book_name character varying, total_sold integer)
    LANGUAGE plpgsql
    AS $$
begin
    return query
    select 
        b.name as book_name,
        sum(od.quantity_sold) as total_sold
    from 
        books b
    join 
        order_details od on b.id = od.book_id
    group by 
        b.name
    order by 
        total_sold desc
    limit 1;
end;
$$;
 $   DROP FUNCTION public.best_seller();
       public               postgres    false                       1255    41210 �   book_add_with_author(character varying, character varying, date, date, character varying, integer, double precision, integer, character varying)    FUNCTION     �  CREATE FUNCTION public.book_add_with_author(author_first_name character varying, author_last_name character varying, born_date date, die_date date, book_name character varying, pages integer, price double precision, quantity integer, book_type character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    new_author_id int;
begin

    insert into author (first_name, last_name, born_date, die_date)
    values (author_first_name, author_last_name, born_date, die_date)
    returning id into new_author_id;


    insert into books (name, author_id, pages, price, quantity, type)
    values (book_name, new_author_id, pages, price, quantity, book_type);
end;
$$;
   DROP FUNCTION public.book_add_with_author(author_first_name character varying, author_last_name character varying, born_date date, die_date date, book_name character varying, pages integer, price double precision, quantity integer, book_type character varying);
       public               postgres    false            �            1255    41207    check_born_die_date()    FUNCTION     �  CREATE FUNCTION public.check_born_die_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	begin
		if new.born_date > current_date then
			raise exception 'o''lgan sana tug''lgan sanadan katta bo''lishi kerak';
		end if;
		if new.die_date is not null and new.die_date < new.born_date then
			raise exception 'tug''ilgan sana bugun sanadan kichik bo''lishi kerak';
			
		end if;

		return new;
	end;
$$;
 ,   DROP FUNCTION public.check_born_die_date();
       public               postgres    false                       1255    41218    check_phone_email_format()    FUNCTION     7  CREATE FUNCTION public.check_phone_email_format() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare 
    n_email varchar; 
    n_phone_number varchar;
begin
    n_email := new.email;
    n_phone_number := new.phone_number;

    if n_email !~ '^^(?!.*\.\.)(?!^\.)[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$' then
        raise exception 'email formati noto''g''ri';
    end if;

    if n_phone_number !~ '^\+998[0-9]{9}$' then
        raise exception 'telefon raqam formati noto''g''ri: +998xxxxxxxxx formatda bo''lishi kerak';
    end if;

    return new;
end;
$_$;
 1   DROP FUNCTION public.check_phone_email_format();
       public               postgres    false            �            1255    41205    check_price_quantity()    FUNCTION     B  CREATE FUNCTION public.check_price_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
	begin 
		if new.price < 0 then 
			raise exception 'Narx 0 dan katta bo''lishi kerak';
		end if;
		if new.quantity <= 0 then
			raise exception 'Kitoblar soni 0dan katta bo''lishi kerak';
		end if;

		return new;
			
	end;
$$;
 -   DROP FUNCTION public.check_price_quantity();
       public               postgres    false                       1255    41213    check_user_phone_and_active()    FUNCTION     a  CREATE FUNCTION public.check_user_phone_and_active() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if new.phone_number is null or length(new.phone_number) = 0 then
        raise exception 'Telefon raqam bo''sh bo''lmasligi kerak';
    end if;
    if exists (select 1 from users where phone_number = new.phone_number and id <> new.id) then
        raise exception 'Telefon raqami noyob bo''lishi kerak';
    end if;
    if new.is_active is not null and new.is_active not in (true, false) then
        raise exception 'is_active true yokifalse bo''lishi kerak';
    end if;

    return new;
end;
$$;
 4   DROP FUNCTION public.check_user_phone_and_active();
       public               postgres    false                       1255    41216    check_user_role_uniqueness()    FUNCTION     e  CREATE FUNCTION public.check_user_role_uniqueness() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if exists (
        select 1 
        from user_role 
        where user_id = new.user_id and role_id = new.role_id
    ) then
        raise exception 'user_id va role_id kombinatsiyasi noyob bo''lishi kerak';
    end if;

    return new;
end;
$$;
 3   DROP FUNCTION public.check_user_role_uniqueness();
       public               postgres    false                       1255    41177    check_valid_with_symbols(text)    FUNCTION     �  CREATE FUNCTION public.check_valid_with_symbols(email text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    combinations text[];
    com text;
    ascii_code int;
BEGIN
   
    combinations := ARRAY[
        '..', '._', '.+', '.-', '.~',
        '_.', '_+', '_-', '_~',
        '+.', '+_', '++', '+-', '+~',
        '-.', '-_', '-+', '--', '-~',
        '~.', '~_', '~+', '~-', '~~',
        '.@', '-@', '~@', '_@', '+@'
    ];

    foreach com in array combinations loop
        if position(com in email) != 0 then
            return true;
        end if;
    end loop;

    ascii_code := ASCII(substring(email from (position('@' in email) - 1) for 1));

    if ascii_code > 0 then
    end if;

    return false;
END;
$$;
 ;   DROP FUNCTION public.check_valid_with_symbols(email text);
       public               postgres    false                       1255    41212    deactivate_user(integer)    FUNCTION     X  CREATE FUNCTION public.deactivate_user(user_id_param integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
    update users
    set is_active = false
    where id = user_id_param and is_active = true;
    if not found then
        raise notice 'User with id % is already deactivated or does not exist', user_id_param;
    end if;
end;
$$;
 =   DROP FUNCTION public.deactivate_user(user_id_param integer);
       public               postgres    false                       1255    41168 h   fn_add_book(character varying, character varying, double precision, integer, character varying, integer)    FUNCTION     �  CREATE FUNCTION public.fn_add_book(b_name character varying, b_author_full_name character varying, b_price double precision, b_quantity integer, b_type character varying, b_pages integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare 
    av_b_name varchar;
    av_author_id int;
begin

    select name into av_b_name 
    from books 
    where name = b_name;

    if av_b_name is not null then 

        update books 
        set quantity = quantity + b_quantity
        where name = b_name;
        return 'Book quantity updated successfully';
    else

        select id into av_author_id 
        from author
        where (first_name || ' ' || last_name) ilike b_author_full_name;

        if av_author_id is null then
            return 'Boshqa authorlar yo`q';
        end if;

        insert into books(name, author_id, price, quantity, book_type, pages)
        values(b_name, av_author_id, b_price, b_quantity, b_type, b_pages);
        return 'Book added successfully';
    end if;
end;
$$;
 �   DROP FUNCTION public.fn_add_book(b_name character varying, b_author_full_name character varying, b_price double precision, b_quantity integer, b_type character varying, b_pages integer);
       public               postgres    false            	           1255    41169 �   fn_add_book_with_author(character varying, double precision, integer, character varying, integer, character varying, character varying, date, date)    FUNCTION       CREATE FUNCTION public.fn_add_book_with_author(b_name character varying, b_price double precision, b_quantity integer, b_type character varying, b_pages integer, a_first_name character varying, a_last_name character varying, a_born_date date, a_die_date date) RETURNS text
    LANGUAGE plpgsql
    AS $$
	declare
		av_author_id int;
		av_b_name varchar;
	begin 
		select id into av_author_id from author where first_name ilike a_first_name
													and last_name ilike a_last_name;
		if av_author_id is null then
			insert into author(first_name, last_name, born_date, die_date)
				values(a_first_name, a_last_name, a_born_date, a_die_date);
				
			select id into av_author_id from author where first_name ilike a_first_name
													and last_name ilike a_last_name;
		end if;
		
		select name into av_b_name from books where name = b_name;
		if av_b_name is not null then
			update books set quantity = quantity + b_quantity, pages = b_pages, price = b_price
				where name = b_name;
			return 'There is a such book, and quantity, price and pages were updated';
		else 
			insert into books(name, author_id, price, quantity, book_type, pages)
				values(b_name, av_author_id, b_price, b_quantity, b_type, b_pages);
			return 'Book is added successfully';
		end if;
	end;
$$;
   DROP FUNCTION public.fn_add_book_with_author(b_name character varying, b_price double precision, b_quantity integer, b_type character varying, b_pages integer, a_first_name character varying, a_last_name character varying, a_born_date date, a_die_date date);
       public               postgres    false            
           1255    41172 #   fn_check_active_user_phone_number()    FUNCTION     �  CREATE FUNCTION public.fn_check_active_user_phone_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	declare 
		n_phone_number varchar;
		av_user_id int;
	begin
		n_phone_number := NEW.phone_number;
		select id into av_user_id from users 
			where phone_number = n_phone_number and is_active = true;
		if av_user_id is not null then
			raise exception 'There is an active user with this phone number: %', n_phone_number;
		end if;
		return new;
	end;
$$;
 :   DROP FUNCTION public.fn_check_active_user_phone_number();
       public               postgres    false                       1255    41176    fn_check_email_validation()    FUNCTION        CREATE FUNCTION public.fn_check_email_validation() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
	declare 
		n_email varchar;
		n_first_letter varchar;
		n_last_letter varchar;
		n_first_letter_ascii int;
		n_last_letter_ascii int;
	begin
		n_email := NEW.email;
		if n_email ~ '^[a-zA-Z0-9._+-~]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' then
			select substring(n_email from 1 for 1) into n_first_letter;
			select ASCII(n_first_letter) into n_first_letter_ascii;

			select substring(n_email from (position('@' in n_email) - 1) for 1) into n_last_letter;
			select ASCII(cast(n_last_letter_ascii as varchar)) into n_last_letter_ascii;
			
			if not((n_first_letter_ascii between 65 and 90) 
				or (n_first_letter_ascii between 97 and 122)) then
				raise exception 'Start is invalid, must start with letter only';
			elsif not((n_last_letter_ascii between 65 and 90)
				or (n_last_letter_ascii between 97 and 122) 
				or (n_last_letter_ascii between 48 and 57)) then
				raise exception 'Before @ is invalid, must end with letter or number only';
			elsif (check_valid_with_symbols(n_email)) then
				raise exception 'Email must not contain continious symbols';
			else
				return NEW;
			end if;
		else 
			raise exception 'This email is invalid: %', n_email;
		end if;
	end;
$_$;
 2   DROP FUNCTION public.fn_check_email_validation();
       public               postgres    false                       1255    41171 5   fn_deactivate_user_by_phone_number(character varying)    FUNCTION     �  CREATE FUNCTION public.fn_deactivate_user_by_phone_number(u_phone_number character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
	declare 
		av_user_id int;
	begin
		select id into av_user_id from users 
			where phone_number = u_phone_number and is_active = true;
		if av_user_id is null then
			return 'There is no such active user';
		end if;
		update users set is_active = false 
			where id = av_user_id;
		return 'Bu user o`chirildi';
	end;
$$;
 [   DROP FUNCTION public.fn_deactivate_user_by_phone_number(u_phone_number character varying);
       public               postgres    false            �            1259    40997    author    TABLE     �   CREATE TABLE public.author (
    id integer NOT NULL,
    first_name character varying(256) NOT NULL,
    last_name character varying(256) NOT NULL,
    born_date date,
    die_date date
);
    DROP TABLE public.author;
       public         heap r       postgres    false            �            1259    41006    books    TABLE       CREATE TABLE public.books (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    author_id integer NOT NULL,
    price double precision,
    quantity integer,
    pages integer,
    type character varying,
    quantity_sold integer DEFAULT 0
);
    DROP TABLE public.books;
       public         heap r       postgres    false            �            1259    41147    get_book_by_name    VIEW     �  CREATE VIEW public.get_book_by_name AS
 SELECT b.name AS "Book Name",
    ((((((((a.first_name)::text || ' '::text) || (a.last_name)::text) || ' ('::text) || EXTRACT(year FROM a.born_date)) || '-'::text) || (COALESCE((EXTRACT(year FROM a.die_date))::character varying, '..'::character varying))::text) || ')'::text) AS "Author Name",
    b.price AS "Price",
    b.quantity AS "Quantity"
   FROM (public.books b
     JOIN public.author a ON ((b.author_id = a.id)));
 #   DROP VIEW public.get_book_by_name;
       public       v       postgres    false    218    218    218    220    220    220    220    218    218            �            1255    41152    fn_get_book_by_name(text)    FUNCTION     �   CREATE FUNCTION public.fn_get_book_by_name(book_name text) RETURNS SETOF public.get_book_by_name
    LANGUAGE plpgsql
    AS $$
	begin 
		return query select * from get_book_by_name where "Book Name" = book_name; 
	end;
$$;
 :   DROP FUNCTION public.fn_get_book_by_name(book_name text);
       public               postgres    false    237            �            1259    41087    order_details    TABLE     �  CREATE TABLE public.order_details (
    id integer NOT NULL,
    address_id integer NOT NULL,
    quantity_sold integer NOT NULL,
    unit_price double precision NOT NULL,
    order_date timestamp without time zone DEFAULT now(),
    book_id integer NOT NULL,
    store_id integer NOT NULL,
    status_id integer,
    CONSTRAINT order_details_unit_price_check CHECK ((unit_price > (0)::double precision))
);
 !   DROP TABLE public.order_details;
       public         heap r       postgres    false            �            1259    41111    orders    TABLE     �   CREATE TABLE public.orders (
    id integer NOT NULL,
    user_id integer NOT NULL,
    employee_id integer NOT NULL,
    order_details_id integer NOT NULL
);
    DROP TABLE public.orders;
       public         heap r       postgres    false            �            1259    41133    status    TABLE     c   CREATE TABLE public.status (
    id integer NOT NULL,
    status character varying(50) NOT NULL
);
    DROP TABLE public.status;
       public         heap r       postgres    false            �            1259    41029    store    TABLE     �   CREATE TABLE public.store (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    address_id integer NOT NULL
);
    DROP TABLE public.store;
       public         heap r       postgres    false            �            1259    41052    users    TABLE     ]  CREATE TABLE public.users (
    id integer NOT NULL,
    first_name character varying(256) NOT NULL,
    last_name character varying(256) NOT NULL,
    address_id integer NOT NULL,
    phone_number character varying(256) NOT NULL,
    password character varying(256) NOT NULL,
    is_active boolean DEFAULT true,
    email character varying(100)
);
    DROP TABLE public.users;
       public         heap r       postgres    false            �            1259    41153    get_full_order_details_view    VIEW     �  CREATE VIEW public.get_full_order_details_view AS
 SELECT o.id AS order_id,
    (((u.first_name)::text || ' '::text) || (u.last_name)::text) AS user_full_name,
    u.phone_number,
    b.name AS book_name,
    (((a.first_name)::text || ' '::text) || (a.last_name)::text) AS author_full_name,
    s.status,
    od.quantity_sold,
    od.unit_price,
    od.order_date,
    st.name AS store_name
   FROM ((((((public.orders o
     JOIN public.order_details od ON ((o.order_details_id = od.id)))
     JOIN public.users u ON ((o.user_id = u.id)))
     JOIN public.books b ON ((b.id = od.book_id)))
     JOIN public.author a ON ((b.author_id = a.id)))
     JOIN public.status s ON ((s.id = od.status_id)))
     JOIN public.store st ON ((st.id = od.store_id)));
 .   DROP VIEW public.get_full_order_details_view;
       public       v       postgres    false    220    236    236    234    234    234    232    232    232    232    232    232    232    228    228    228    228    224    224    220    220    218    218    218            �            1255    41158 )   fn_get_order_details_by_order_id(integer)    FUNCTION     �   CREATE FUNCTION public.fn_get_order_details_by_order_id(o_id integer) RETURNS SETOF public.get_full_order_details_view
    LANGUAGE plpgsql
    AS $$
	begin
		return query select * from get_full_order_details_view 
						where order_id = o_id;
	end;
$$;
 E   DROP FUNCTION public.fn_get_order_details_by_order_id(o_id integer);
       public               postgres    false    238            �            1255    41159 *   fn_reduce_book_quantity_by_quantity_sold()    FUNCTION     �  CREATE FUNCTION public.fn_reduce_book_quantity_by_quantity_sold() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	declare 
		sold_book_quantity int;
		sold_book_id int;
		book_quantity int;
	begin 
		sold_book_quantity := NEW.quantity_sold;
		sold_book_id := NEW.book_id;
		select quantity into book_quantity from books where id = sold_book_id;

		if sold_book_quantity <= book_quantity then
			update books set quantity = quantity - sold_book_quantity 
				where id = sold_book_id;
			raise notice 'Book is successfully updated - %', sold_book_id;
		else
			raise exception 'Number of books is not enough - %', sold_book_id;
		end if;
		return new;
	end;
$$;
 A   DROP FUNCTION public.fn_reduce_book_quantity_by_quantity_sold();
       public               postgres    false            �            1255    41191    get_author_partition()    FUNCTION     .  CREATE FUNCTION public.get_author_partition() RETURNS TABLE(author_id integer, author_name character varying, book_name character varying, price double precision, pages integer, type character varying)
    LANGUAGE plpgsql
    AS $$
begin
    return query select * from author_partition_view;
end;
$$;
 -   DROP FUNCTION public.get_author_partition();
       public               postgres    false            �            1255    41203    get_book_shop_details()    FUNCTION     �  CREATE FUNCTION public.get_book_shop_details() RETURNS TABLE(book_name text, author_name text, price double precision, pages integer, type character varying, author_id integer)
    LANGUAGE plpgsql
    AS $$
begin
    return query
    select 
        b.name::text as book_name, 
        concat(a.first_name, ' ', a.last_name) as author_name,
        b.price,
        b.pages,
        b.type,
        b.author_id
    from books b
    join author a on b.author_id = a.id
    order by b.price;
end;
$$;
 .   DROP FUNCTION public.get_book_shop_details();
       public               postgres    false            �            1255    41179    get_books()    FUNCTION       CREATE FUNCTION public.get_books() RETURNS TABLE(book_name character varying, author_name character varying, price double precision, pages integer, type character varying)
    LANGUAGE plpgsql
    AS $$
begin
    return query select * from books_view;
end;
$$;
 "   DROP FUNCTION public.get_books();
       public               postgres    false            �            1255    41186    get_books_by_price()    FUNCTION       CREATE FUNCTION public.get_books_by_price() RETURNS TABLE(book_name character varying, author_name character varying, price double precision, pages integer, type character varying)
    LANGUAGE plpgsql
    AS $$
begin
    return query select * from books_by_price_view;
end;
$$;
 +   DROP FUNCTION public.get_books_by_price();
       public               postgres    false            �            1255    41202    get_order_details()    FUNCTION     .  CREATE FUNCTION public.get_order_details() RETURNS TABLE(order_id integer, phone_number character varying, user_full character varying, book_name character varying, order_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
begin
    return query select * from order_details_view;
end;
$$;
 *   DROP FUNCTION public.get_order_details();
       public               postgres    false                       1255    41222    most_sold_books(integer)    FUNCTION     �  CREATE FUNCTION public.most_sold_books(limit_count integer) RETURNS TABLE(book_name character varying, total_sold integer)
    LANGUAGE plpgsql
    AS $$
begin
    return query
    select 
        b.name as book_name,
        sum(od.quantity_sold) as total_sold
    from 
        books b
    join 
        order_details od on b.id = od.book_id
    group by 
        b.name
    order by 
        total_sold desc
    limit limit_count;
end;
$$;
 ;   DROP FUNCTION public.most_sold_books(limit_count integer);
       public               postgres    false                       1255    41220 )   order_history_by_phone(character varying)    FUNCTION     �  CREATE FUNCTION public.order_history_by_phone(phone character varying) RETURNS TABLE(order_id integer, user_name character varying, book_name character varying, quantity_sold integer, order_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
begin
    return query
    select 
        o.id as order_id,
        concat(u.first_name, ' ', u.last_name)::varchar as user_name,
        b.name as book_name, od.quantity_sold, od.order_date
    from 
        orders o
    join 
        users u on o.user_id = u.id
    join 
        order_details od on o.order_details_id = od.id
    join 
        books b on od.book_id = b.id
    where 
        u.phone_number = phone
    order by 
        od.order_date desc;
end;
$$;
 F   DROP FUNCTION public.order_history_by_phone(phone character varying);
       public               postgres    false                       1255    41223    update_book_quantity_sold()    FUNCTION     �   CREATE FUNCTION public.update_book_quantity_sold() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    update books
    set quantity_sold = quantity_sold + new.quantity_sold
    where id = new.book_id;

    return new;
end;
$$;
 2   DROP FUNCTION public.update_book_quantity_sold();
       public               postgres    false            �            1259    41018    address    TABLE     �   CREATE TABLE public.address (
    id integer NOT NULL,
    address character varying(256) NOT NULL,
    city character varying NOT NULL,
    country character varying(256) NOT NULL,
    postal_code character varying(256) NOT NULL
);
    DROP TABLE public.address;
       public         heap r       postgres    false            �            1259    41017    address_id_seq    SEQUENCE     �   CREATE SEQUENCE public.address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.address_id_seq;
       public               postgres    false    222            �           0    0    address_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.address_id_seq OWNED BY public.address.id;
          public               postgres    false    221            �            1259    40996    author_id_seq    SEQUENCE     �   CREATE SEQUENCE public.author_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.author_id_seq;
       public               postgres    false    218            �           0    0    author_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.author_id_seq OWNED BY public.author.id;
          public               postgres    false    217            �            1259    41187    author_partition_view    VIEW     8  CREATE VIEW public.author_partition_view AS
 SELECT a.id AS author_id,
    (concat(a.first_name, ' ', a.last_name))::character varying AS author_name,
    b.name AS book_name,
    b.price,
    b.pages,
    b.type
   FROM (public.author a
     LEFT JOIN public.books b ON ((a.id = b.author_id)))
  ORDER BY a.id;
 (   DROP VIEW public.author_partition_view;
       public       v       postgres    false    218    220    218    220    220    220    220    218            �            1259    41182    books_by_price_view    VIEW       CREATE VIEW public.books_by_price_view AS
 SELECT b.name AS book_name,
    (concat(a.first_name, ' ', a.last_name))::character varying AS author_name,
    b.price,
    b.pages,
    b.type
   FROM (public.books b
     JOIN public.author a ON ((b.author_id = a.id)))
  ORDER BY b.price;
 &   DROP VIEW public.books_by_price_view;
       public       v       postgres    false    218    218    218    220    220    220    220    220            �            1259    41005    books_id_seq    SEQUENCE     �   CREATE SEQUENCE public.books_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.books_id_seq;
       public               postgres    false    220            �           0    0    books_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.books_id_seq OWNED BY public.books.id;
          public               postgres    false    219            �            1259    41086    order_details_id_seq    SEQUENCE     �   CREATE SEQUENCE public.order_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.order_details_id_seq;
       public               postgres    false    232            �           0    0    order_details_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.order_details_id_seq OWNED BY public.order_details.id;
          public               postgres    false    231            �            1259    41197    order_details_view    VIEW     �  CREATE VIEW public.order_details_view AS
 SELECT od.id AS order_id,
    u.phone_number,
    (concat(u.first_name, ' ', u.last_name))::character varying AS user_full,
    b.name AS book_name,
    od.order_date
   FROM (((public.order_details od
     JOIN public.orders o ON ((od.id = o.order_details_id)))
     JOIN public.users u ON ((o.user_id = u.id)))
     JOIN public.books b ON ((od.book_id = b.id)))
  ORDER BY od.id;
 %   DROP VIEW public.order_details_view;
       public       v       postgres    false    220    220    228    228    228    228    232    232    232    234    234            �            1259    41110    orders_id_seq    SEQUENCE     �   CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.orders_id_seq;
       public               postgres    false    234            �           0    0    orders_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;
          public               postgres    false    233            �            1259    41043    role    TABLE     e   CREATE TABLE public.role (
    id integer NOT NULL,
    role_name character varying(256) NOT NULL
);
    DROP TABLE public.role;
       public         heap r       postgres    false            �            1259    41042    role_id_seq    SEQUENCE     �   CREATE SEQUENCE public.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.role_id_seq;
       public               postgres    false    226            �           0    0    role_id_seq    SEQUENCE OWNED BY     ;   ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;
          public               postgres    false    225            �            1259    41160    roles    TABLE     b   CREATE TABLE public.roles (
    role_id integer NOT NULL,
    role_name character varying(100)
);
    DROP TABLE public.roles;
       public         heap r       postgres    false            �            1259    41132    status_id_seq    SEQUENCE     �   CREATE SEQUENCE public.status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.status_id_seq;
       public               postgres    false    236            �           0    0    status_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.status_id_seq OWNED BY public.status.id;
          public               postgres    false    235            �            1259    41028    store_id_seq    SEQUENCE     �   CREATE SEQUENCE public.store_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.store_id_seq;
       public               postgres    false    224            �           0    0    store_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.store_id_seq OWNED BY public.store.id;
          public               postgres    false    223            �            1259    41192    user_orders_view    VIEW     �  CREATE VIEW public.user_orders_view AS
 SELECT u.id AS user_id,
    (concat(u.first_name, ' ', u.last_name))::character varying AS user_name,
    o.id AS order_id,
    od.quantity_sold,
    od.unit_price,
    ((od.quantity_sold)::double precision * od.unit_price) AS total_price,
    od.order_date
   FROM ((public.users u
     JOIN public.orders o ON ((u.id = o.user_id)))
     JOIN public.order_details od ON ((o.order_details_id = od.id)))
  ORDER BY u.id, od.order_date;
 #   DROP VIEW public.user_orders_view;
       public       v       postgres    false    232    232    234    232    234    234    228    228    228    232            �            1259    41070 	   user_role    TABLE     w   CREATE TABLE public.user_role (
    id integer NOT NULL,
    role_id integer NOT NULL,
    user_id integer NOT NULL
);
    DROP TABLE public.user_role;
       public         heap r       postgres    false            �            1259    41069    user_role_id_seq    SEQUENCE     �   CREATE SEQUENCE public.user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.user_role_id_seq;
       public               postgres    false    230            �           0    0    user_role_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.user_role_id_seq OWNED BY public.user_role.id;
          public               postgres    false    229            �            1259    41051    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public               postgres    false    228            �           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public               postgres    false    227            �           2604    41021 
   address id    DEFAULT     h   ALTER TABLE ONLY public.address ALTER COLUMN id SET DEFAULT nextval('public.address_id_seq'::regclass);
 9   ALTER TABLE public.address ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    221    222    222            �           2604    41000 	   author id    DEFAULT     f   ALTER TABLE ONLY public.author ALTER COLUMN id SET DEFAULT nextval('public.author_id_seq'::regclass);
 8   ALTER TABLE public.author ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    218    217    218            �           2604    41009    books id    DEFAULT     d   ALTER TABLE ONLY public.books ALTER COLUMN id SET DEFAULT nextval('public.books_id_seq'::regclass);
 7   ALTER TABLE public.books ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    219    220    220            �           2604    41090    order_details id    DEFAULT     t   ALTER TABLE ONLY public.order_details ALTER COLUMN id SET DEFAULT nextval('public.order_details_id_seq'::regclass);
 ?   ALTER TABLE public.order_details ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    232    231    232            �           2604    41114 	   orders id    DEFAULT     f   ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);
 8   ALTER TABLE public.orders ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    234    233    234            �           2604    41046    role id    DEFAULT     b   ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);
 6   ALTER TABLE public.role ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    226    225    226            �           2604    41136 	   status id    DEFAULT     f   ALTER TABLE ONLY public.status ALTER COLUMN id SET DEFAULT nextval('public.status_id_seq'::regclass);
 8   ALTER TABLE public.status ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    235    236    236            �           2604    41032    store id    DEFAULT     d   ALTER TABLE ONLY public.store ALTER COLUMN id SET DEFAULT nextval('public.store_id_seq'::regclass);
 7   ALTER TABLE public.store ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    224    223    224            �           2604    41073    user_role id    DEFAULT     l   ALTER TABLE ONLY public.user_role ALTER COLUMN id SET DEFAULT nextval('public.user_role_id_seq'::regclass);
 ;   ALTER TABLE public.user_role ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    229    230    230            �           2604    41055    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    227    228    228            �          0    41018    address 
   TABLE DATA           J   COPY public.address (id, address, city, country, postal_code) FROM stdin;
    public               postgres    false    222   ��       �          0    40997    author 
   TABLE DATA           P   COPY public.author (id, first_name, last_name, born_date, die_date) FROM stdin;
    public               postgres    false    218   _�       �          0    41006    books 
   TABLE DATA           a   COPY public.books (id, name, author_id, price, quantity, pages, type, quantity_sold) FROM stdin;
    public               postgres    false    220   ��       �          0    41087    order_details 
   TABLE DATA           |   COPY public.order_details (id, address_id, quantity_sold, unit_price, order_date, book_id, store_id, status_id) FROM stdin;
    public               postgres    false    232   V�       �          0    41111    orders 
   TABLE DATA           L   COPY public.orders (id, user_id, employee_id, order_details_id) FROM stdin;
    public               postgres    false    234   s�       �          0    41043    role 
   TABLE DATA           -   COPY public.role (id, role_name) FROM stdin;
    public               postgres    false    226   ��       �          0    41160    roles 
   TABLE DATA           3   COPY public.roles (role_id, role_name) FROM stdin;
    public               postgres    false    239   G�       �          0    41133    status 
   TABLE DATA           ,   COPY public.status (id, status) FROM stdin;
    public               postgres    false    236   d�       �          0    41029    store 
   TABLE DATA           5   COPY public.store (id, name, address_id) FROM stdin;
    public               postgres    false    224   ��       �          0    41070 	   user_role 
   TABLE DATA           9   COPY public.user_role (id, role_id, user_id) FROM stdin;
    public               postgres    false    230   ��       �          0    41052    users 
   TABLE DATA           p   COPY public.users (id, first_name, last_name, address_id, phone_number, password, is_active, email) FROM stdin;
    public               postgres    false    228   ��       �           0    0    address_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.address_id_seq', 26, true);
          public               postgres    false    221            �           0    0    author_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.author_id_seq', 24, true);
          public               postgres    false    217            �           0    0    books_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.books_id_seq', 24, true);
          public               postgres    false    219            �           0    0    order_details_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.order_details_id_seq', 2, true);
          public               postgres    false    231            �           0    0    orders_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.orders_id_seq', 1, false);
          public               postgres    false    233            �           0    0    role_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.role_id_seq', 12, true);
          public               postgres    false    225            �           0    0    status_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.status_id_seq', 1, false);
          public               postgres    false    235            �           0    0    store_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.store_id_seq', 1, false);
          public               postgres    false    223            �           0    0    user_role_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.user_role_id_seq', 17, true);
          public               postgres    false    229            �           0    0    users_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.users_id_seq', 35, true);
          public               postgres    false    227            �           2606    41027    address address_address_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_address_key UNIQUE (address);
 E   ALTER TABLE ONLY public.address DROP CONSTRAINT address_address_key;
       public                 postgres    false    222            �           2606    41025    address address_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.address DROP CONSTRAINT address_pkey;
       public                 postgres    false    222            �           2606    41004    author author_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.author
    ADD CONSTRAINT author_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.author DROP CONSTRAINT author_pkey;
       public                 postgres    false    218            �           2606    41011    books books_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.books DROP CONSTRAINT books_pkey;
       public                 postgres    false    220            �           2606    41094     order_details order_details_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.order_details DROP CONSTRAINT order_details_pkey;
       public                 postgres    false    232            �           2606    41116    orders orders_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_pkey;
       public                 postgres    false    234            �           2606    41048    role role_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.role DROP CONSTRAINT role_pkey;
       public                 postgres    false    226            �           2606    41050    role role_role_name_key 
   CONSTRAINT     W   ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_role_name_key UNIQUE (role_name);
 A   ALTER TABLE ONLY public.role DROP CONSTRAINT role_role_name_key;
       public                 postgres    false    226            �           2606    41164    roles roles_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);
 :   ALTER TABLE ONLY public.roles DROP CONSTRAINT roles_pkey;
       public                 postgres    false    239            �           2606    41138    status status_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.status DROP CONSTRAINT status_pkey;
       public                 postgres    false    236            �           2606    41140    status status_status_key 
   CONSTRAINT     U   ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_status_key UNIQUE (status);
 B   ALTER TABLE ONLY public.status DROP CONSTRAINT status_status_key;
       public                 postgres    false    236            �           2606    41036    store store_name_key 
   CONSTRAINT     O   ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_name_key UNIQUE (name);
 >   ALTER TABLE ONLY public.store DROP CONSTRAINT store_name_key;
       public                 postgres    false    224            �           2606    41034    store store_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.store DROP CONSTRAINT store_pkey;
       public                 postgres    false    224            �           2606    41075    user_role user_role_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT user_role_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.user_role DROP CONSTRAINT user_role_pkey;
       public                 postgres    false    230            �           2606    41175    users users_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
       public                 postgres    false    228            �           2606    41059    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public                 postgres    false    228            �           2620    41208    author check_dates_trigger    TRIGGER     �   CREATE TRIGGER check_dates_trigger BEFORE INSERT OR UPDATE ON public.author FOR EACH ROW EXECUTE FUNCTION public.check_born_die_date();
 3   DROP TRIGGER check_dates_trigger ON public.author;
       public               postgres    false    253    218            �           2620    41206 !   books check_price_quantity_tigger    TRIGGER     �   CREATE TRIGGER check_price_quantity_tigger BEFORE INSERT OR UPDATE ON public.books FOR EACH ROW EXECUTE FUNCTION public.check_price_quantity();
 :   DROP TRIGGER check_price_quantity_tigger ON public.books;
       public               postgres    false    252    220            �           2620    41173 '   users tg_check_active_user_phone_number    TRIGGER     �   CREATE TRIGGER tg_check_active_user_phone_number BEFORE INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.fn_check_active_user_phone_number();
 @   DROP TRIGGER tg_check_active_user_phone_number ON public.users;
       public               postgres    false    266    228            �           2620    41178    users tg_check_email_validation    TRIGGER     �   CREATE TRIGGER tg_check_email_validation BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.fn_check_email_validation();
 8   DROP TRIGGER tg_check_email_validation ON public.users;
       public               postgres    false    267    228            �           2620    41165 6   order_details tg_reduce_book_quantity_by_quantity_sold    TRIGGER     �   CREATE TRIGGER tg_reduce_book_quantity_by_quantity_sold BEFORE INSERT ON public.order_details FOR EACH ROW EXECUTE FUNCTION public.fn_reduce_book_quantity_by_quantity_sold();
 O   DROP TRIGGER tg_reduce_book_quantity_by_quantity_sold ON public.order_details;
       public               postgres    false    246    232            �           2620    41219 #   users trigger_check_phone_and_email    TRIGGER     �   CREATE TRIGGER trigger_check_phone_and_email BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.check_phone_email_format();
 <   DROP TRIGGER trigger_check_phone_and_email ON public.users;
       public               postgres    false    228    274            �           2620    41224 *   order_details update_book_quantity_trigger    TRIGGER     �   CREATE TRIGGER update_book_quantity_trigger AFTER INSERT ON public.order_details FOR EACH ROW EXECUTE FUNCTION public.update_book_quantity_sold();
 C   DROP TRIGGER update_book_quantity_trigger ON public.order_details;
       public               postgres    false    277    232            �           2620    41214    users user_phone_check_trigger    TRIGGER     �   CREATE TRIGGER user_phone_check_trigger BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.check_user_phone_and_active();
 7   DROP TRIGGER user_phone_check_trigger ON public.users;
       public               postgres    false    228    271            �           2620    41217 "   user_role user_role_unique_trigger    TRIGGER     �   CREATE TRIGGER user_role_unique_trigger BEFORE INSERT ON public.user_role FOR EACH ROW EXECUTE FUNCTION public.check_user_role_uniqueness();
 ;   DROP TRIGGER user_role_unique_trigger ON public.user_role;
       public               postgres    false    273    230            �           2606    41037    store fk_address_id    FK CONSTRAINT     w   ALTER TABLE ONLY public.store
    ADD CONSTRAINT fk_address_id FOREIGN KEY (address_id) REFERENCES public.address(id);
 =   ALTER TABLE ONLY public.store DROP CONSTRAINT fk_address_id;
       public               postgres    false    224    222    4817            �           2606    41064    users fk_address_id    FK CONSTRAINT     w   ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_address_id FOREIGN KEY (address_id) REFERENCES public.address(id);
 =   ALTER TABLE ONLY public.users DROP CONSTRAINT fk_address_id;
       public               postgres    false    222    4817    228            �           2606    41095    order_details fk_address_id    FK CONSTRAINT        ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT fk_address_id FOREIGN KEY (address_id) REFERENCES public.address(id);
 E   ALTER TABLE ONLY public.order_details DROP CONSTRAINT fk_address_id;
       public               postgres    false    232    4817    222            �           2606    41012    books fk_author_id    FK CONSTRAINT     t   ALTER TABLE ONLY public.books
    ADD CONSTRAINT fk_author_id FOREIGN KEY (author_id) REFERENCES public.author(id);
 <   ALTER TABLE ONLY public.books DROP CONSTRAINT fk_author_id;
       public               postgres    false    218    220    4811            �           2606    41100    order_details fk_book_id    FK CONSTRAINT     w   ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT fk_book_id FOREIGN KEY (book_id) REFERENCES public.books(id);
 B   ALTER TABLE ONLY public.order_details DROP CONSTRAINT fk_book_id;
       public               postgres    false    220    4813    232            �           2606    41122    orders fk_employee_id    FK CONSTRAINT     x   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_employee_id FOREIGN KEY (employee_id) REFERENCES public.users(id);
 ?   ALTER TABLE ONLY public.orders DROP CONSTRAINT fk_employee_id;
       public               postgres    false    234    228    4829            �           2606    41127    orders fk_order_details_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_order_details_id FOREIGN KEY (order_details_id) REFERENCES public.order_details(id);
 D   ALTER TABLE ONLY public.orders DROP CONSTRAINT fk_order_details_id;
       public               postgres    false    234    232    4833            �           2606    41076    user_role fk_role_id    FK CONSTRAINT     r   ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT fk_role_id FOREIGN KEY (role_id) REFERENCES public.role(id);
 >   ALTER TABLE ONLY public.user_role DROP CONSTRAINT fk_role_id;
       public               postgres    false    230    226    4823            �           2606    41141    order_details fk_status_id    FK CONSTRAINT     |   ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT fk_status_id FOREIGN KEY (status_id) REFERENCES public.status(id);
 D   ALTER TABLE ONLY public.order_details DROP CONSTRAINT fk_status_id;
       public               postgres    false    4837    236    232            �           2606    41105    order_details fk_store_id    FK CONSTRAINT     y   ALTER TABLE ONLY public.order_details
    ADD CONSTRAINT fk_store_id FOREIGN KEY (store_id) REFERENCES public.store(id);
 C   ALTER TABLE ONLY public.order_details DROP CONSTRAINT fk_store_id;
       public               postgres    false    4821    232    224            �           2606    41081    user_role fk_user_id    FK CONSTRAINT     s   ALTER TABLE ONLY public.user_role
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id);
 >   ALTER TABLE ONLY public.user_role DROP CONSTRAINT fk_user_id;
       public               postgres    false    4829    230    228            �           2606    41117    orders fk_user_id    FK CONSTRAINT     p   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id);
 ;   ALTER TABLE ONLY public.orders DROP CONSTRAINT fk_user_id;
       public               postgres    false    228    234    4829            �   |  x�e��n�0��˧�� �;GYq�4ujXq��l,�&L�-9��w)٭��A���|C	R%|n�j��-TM0n�n��a]�s�1i�����I�NC����?k� �'���_���c%6�E�K����F(䌫2a)H!���7t������Y�(�2PB�	���Sw���֏0/e��l�rHD�K]c��B+sҡF�Vt�6�5H!�R��W��k�m Tm�-|���F���\Hɦ����F;^Ц=T�vܺ�]���{0$�B��+������v��q���Ʌ�"J�����o,�����0?hף:&p#�L����0�F���GBW ��#/�V[}<OtW��(�m��#F�G�5��޵��p��s�����^_�m|G�_�/��˂&^3�c���E���z���ɑ���>a���kG��e�"K9���ZIp���#�%R@cGf:X��N��>.,��#��F��,1P%��M�$�)*	S1�F��:r�&P�A�(�s}�+��@7�R�-��F�{���Џ!>�}��+6�"�O7EH���N۸nI�j
�\�G4�H3�2��L$_�����Bz��М���qp2�����^��vQ�.�e������&1�      �   z  x���AN�0E��S���ı�d11Ì4 ذ1�i"B̸�"��\�rz?�H.�~~կ:�eK��h�s�KMЀ���_��t�cC�<��V��������U?}|�����vOI��k�i57�ݾT-��1���nJ#�9����UKxe�2t1�^$��u���T����˾l���t��p'2��@�Ym�^9��2]�a7�Ѱ�&ȷ�W6��q�)}�-������[���^EŮ:���`I����x�*�G�U"��	
���1�&:I�r�9��!Ԁ�z>�Ұ�8�M���i����f��7y��&���_��-�X#�� F�������0I��(e�U,V�d�U��� N�8�Fkpr���F)�	˝�9      �   ]  x���ok�0�__?�}�IӦ�^
��SP�d�e�b:��/��lJ��7����a���9��`񨪀ǰzn�8J<�����-e����*I(�Ĺ��F�5���-����p,�I����;.�b�cS(.�f0��ދ�6{q �Wk�$;#9��;�����KBJ3M8i��$��&/L�\#	r`i�iH-ai�I�5
���F�7e%���!��5�%N��q�AJ(���X��J0vqD���
�!�s�������]�����6N8����2��t�?i�W�G�_���ۀ�C톖��o��~���;>7�����xtr%:��^Ӂ�U�;V�(�~ �d�      �      x������ � �      �      x������ � �      �   �   x�=�;�@k�{D�SB��@A��Y%V�"ؑw	N��Hgy��8����]=�������p�8��'���w�!F��O�k8�<]>��$n��.0�BkR��h����1��������ݩW���)��;8���m<����p�ΐ�p#��Lfs8T�V�Y6������F
      �      x������ � �      �      x������ � �      �      x������ � �      �   I   x����Pѳ���N/�_z��[�i
���`*X
����Q�[�ᬝw��Ľ��n<��j����{�X      �   b  x�}T�n�0<���gC�����<��A� �\h��K�K)6ܯ�R��.��I;���p��΀�q�H�%yQ����;���xy�g�q�[����8�������Y�yf�^`aW�6���s-�TI�	��qE�״o������[��$&6IX4��sN
϶��np�ݾ��D)!��0@>M�?k��:LB&2	������Q�H)�S7�Ó>��#��'᤿����#��n[т�vM��&6A���cۣJ%�M���b�}o[�%&JA�z�b�q������]�|�ޓT�n��-���%�uc����ĳ�3�B���0S~��|`�]�c���4sVy������W�%6�o���s!�T
:t<e�s\��{�d�K�7ɈQ"k�()��{��({;C��k�)s&c��ޥ92R��3���<#���yCɘ�,*j��8R��cw��+	�ǂ�N*H���;JĜ��J�K>%���y�\�)D��2µ:�H�$����)OE*S����B$���t���RV��2Y I$��9�M�xAc��)\r���))��M��l���$�P�л$&��f�sI�JbO�3n/�g��_J�e�     