use husky_app;
-- register user
drop procedure if exists register_user;

delimiter //
create procedure register_user
(
	in email_param varchar(45),
    in username_param varchar(20),
    in password_param varchar(45)
)
begin
	-- variable declarations
    declare email_var varchar(45);
    declare username_var varchar(20);
    declare password_var varchar(45);

	declare message varchar(255); -- The error message

    -- select relevant values into variables
    
    -- email
    select email_param
    into email_var;
    -- username
    select username_param
    into username_var;
    -- password
    select password_param
    into password_var;


    -- username validation
    if length(username_var) < 5 then
	select concat('Please enter a username with at least 5 characters') into message;
	signal sqlstate 'HY000' set message_text = message;
	end if;
    
	-- password validation
    if length(password_var) < 8 
    then
	select concat('Password must be at least 8 characters long') into message;
	signal sqlstate 'HY000' set message_text = message;
	end if;
    
    -- email validation
    if email_var not like '%@northeastern.edu%'
    then
	select concat('You must use your Northeastern email address to register (@northeastern.edu)') into message;
	signal sqlstate 'HY000' set message_text = message;
	end if;
    
    -- No exceptions thrown, so insert the prescription record
    insert into `account_user` (user_name, user_email, user_reg_date, user_password) values 
    ( username_var, email_var, curDate(), password_var);

end //
delimiter ;

DELIMITER // 
DROP procedure if exists promote;
      CREATE PROCEDURE promote (IN user_act int, forum int)
		BEGIN
			IF NOT EXISTS (SELECT * from forum_rank where user_id = user_act and forum_id = forum and badge_id = 2) THEN 
				INSERT INTO forum_rank values (user_act, 2, forum);
			END IF;
        END;//
        
DROP PROCEDURE if exists demote;
        CREATE PROCEDURE demote (IN user_act int, forum int)
			BEGIN
				IF EXISTS (SELECT * from forum_rank where user_id = user_act and forum_id = forum and badge_id = 2) THEN 
					DELETE FROM forum_rank where user_id = user_act and forum_id = forum and badge_id = 2;
				END IF;
			END;//
        
	  DELIMITER ;
      
      drop function if exists getRating;
create function getRating (post int) returns int deterministic 
		return ((SELECT count(user_id) from rating where post_id = post and pos_neg = 1) 
				- (SELECT count(user_id) from rating where post_id = post and pos_neg = 0));


drop function if exists getUserRating;
create function getUserRating(userID int) returns int deterministic
    return (select sum(rtng) from (select getRating(post_id) rtng, post_id 
		from post where post.user_id = userID group by post_id) a1);



drop function if exists forumActivity;
DELIMITER //
create function forumActivity(forumID int) returns int deterministic
begin
	declare RowCount int;
	return (select count(post_id) from post where forum_id = forumID and post_date >= DATE_ADD(now(), interval -3 YEAR) );
end//
DELIMITER ;


-- report post procedure 
drop procedure if exists report_post;

delimiter //
create procedure report_post
(
    in comment_param varchar(45),
    in post_id_param int
)
begin
	-- variable declarations
	declare comment_var varchar(45);
    declare post_id_var varchar(45);
    declare report_date_var varchar(45);
    
    declare message varchar(255); -- The error message

    -- select relevant values into variables
    
     -- comment
    select comment_param
    into comment_var;
    
      -- post_id
    select post_id
    from post
    where post_id = post_id_var;
    
    -- report_date
    select report_date
    from report
    where report_date = report_date_var;
  
	-- comment validation
    if comment_var = '' then
	select concat('Please indicate a reason for reporting this post') into message;
	signal sqlstate 'HY000' set message_text = message;
    else 
    set report_date_var = CURDATE();
	end if;
    
    -- No exceptions thrown, so insert the user record
     insert into report ( comment, post_id) values 
    (comment_var, post_id_var);
   


end //
delimiter ;


select * from post;	


select * from report;

-- add post procedure
drop procedure if exists add_post;

delimiter //
create procedure add_post

(
	in contents_param varchar(300),
    in title_param varchar(45),
    in user_id_param varchar(45),
    in forum_id_param int
)
begin
	-- variable declarations
    declare contents_var varchar(45);
    declare title_var varchar(20);
    declare user_id_var varchar(45);
    declare forum_id_var int;
    
    declare message varchar(200);

    -- select relevant values into variables
    
    -- contents
    select contents_param
    into contents_var;
    -- title
    select title_param
    into title_var;
    -- user_id
    select user_id_param
    into user_id_var;
    -- forum_id
	select forum_id_param
    into forum_id_var;

    -- contents validation
    if contents_var = '' then
	select concat('Post cannot be empty') into message;
	signal sqlstate 'HY000' set message_text = message;
	end if;
    
    -- title validation
    if title_var = '' then
	select concat('Please enter a title ') into message;
	signal sqlstate 'HY000' set message_text = message;
	end if;
    
    -- No exceptions thrown, so insert the user record
    insert into `post` (user_id, forum_id, parent_post_id, post_date, archived, title, contents) values 
    (user_id_var, forum_id_var, null, curDate(), false, title_var, contents_var);

end //
delimiter ;



-- add forum

drop procedure if exists add_forum;

delimiter //
create procedure add_forum
(
    in name_param varchar(45)
    
)
begin
	-- variable declarations
    declare name_var varchar(20);
  
    
    declare message varchar(200);

    -- select relevant values into variables
    

    -- title
    select name_param
    into name_var;


    -- contents validation
    if name_var = '' then
	select concat('Post cannot be empty') into message;
	signal sqlstate 'HY000' set message_text = message;
	end if;
  
    -- No exceptions thrown, so insert the user record
    insert into `forum` (forum_name) values 
    (name_var);

end //
delimiter ;

-- get posts 

drop procedure if exists getPosts;
DELIMITER //
create procedure getPosts(forumID int) 
begin
declare forum_id_var int;
select forumID into forum_id_var;
set sql_mode = '';
select * from post where forum_id_var = forum_id;

end//
DELIMITER ;
call getPosts(1);
select * from post;
drop procedure if exists getForums;
DELIMITER //
create procedure getForums() 
begin
select forum_name from forum;
end//
DELIMITER ;


-- get forum id from name
drop procedure if exists getForumIDFromName;
DELIMITER //
create procedure getForumIDFromName(forumName varchar(20)) 
begin
declare forum_name_var varchar(45);
set forum_name_var = forumName;
select forum_id from forum where forum_name = (forum_name_var) limit 1;
end//
DELIMITER ;


-- select forum_id from forum where forum_name like ('%1200isplenty%');
-- call getForumIDFromName('art');
select * from forum;

-- get posts from forum name 
drop procedure if exists getPosts2;
DELIMITER //
create procedure getPosts2(forumName varchar(20)) 
begin
declare forum_name_var varchar(20);
select forumName into forum_name_var;
set sql_mode = '';
select title, contents from post join forum using (forum_id)
where forum_name like concat('%',forum_name_var, '%');

end//
DELIMITER ;
call getPosts2('test');

DROP TRIGGER IF EXISTS remove_follow;
	DELIMITER //
	CREATE TRIGGER remove_follow  AFTER INSERT ON ban FOR EACH ROW
    BEGIN
    
		DECLARE banned_user INT;
        DECLARE forum_ban INT;
        
        SET @report_id = NEW.report_id;
        SET @banned_user = (Select post.user_id from report left outer join post on report.post_id = post.post_id where report.report_id = new.report_id);
        SET @forum_ban = (Select post.forum_id from report left outer join post on report.post_id = post.post_id where report.report_id = new.report_id);
		        
		DELETE FROM follower where follower.user_id = @banned_user AND @forum_ban = follower.forum_id;
        DELETE FROM forum_rank where forum_rank.user_id = @banned_user AND forum_rank.forum_id = @forum_ban;
        UPDATE post SET archived = 1 where post.user_id = @banned_user and post.forum_id = @forum_ban;
    
    END;//
    DELIMITER ;
    
      drop trigger if exists check_rating;

   DELIMITER //
   CREATE TRIGGER check_rating after insert on rating for each row
		begin
			UPDATE post set archived = 1 where 
				(getRating(post_id)) < -10;
        end;//
        
	-- REMOVED ARCHIVE_CHILDREN.
        
	DELIMITER ;
    select * from post;
    
    drop procedure if exists change_username;
delimiter //
create procedure change_username
(in user_id_param varchar(45),in new_username_param varchar(20))
begin
	-- variable declarations
    declare user_id_var varchar(45);
    declare username_var varchar(20);
    declare message varchar(255); -- The error message
    -- user_id
    select user_id_param
    into user_id_var;
    -- username
    select new_username_param
    into username_var;
    -- username validation
    if length(username_var) < 5 then
	select concat('Please enter a username with at least 5 characters') into message;
	signal sqlstate 'HY000' set message_text = message;
	end if;
    -- No exceptions thrown, so update the username
    UPDATE `account_user`
	SET user_name = username_var
	WHERE user_id = user_id_var;

end //
delimiter ;
   
   
drop procedure if exists change_password;
delimiter //
create procedure change_password
(in user_id_param varchar(45),in new_password_param varchar(20))
begin
	-- variable declarations
    declare user_id_var varchar(45); -- user id is a lot less useful than user email or user name for the purposes of this for front end
    declare password_var varchar(20);
	declare message varchar(255); -- The error message

    
    -- user_id
    select user_id_param
    into user_id_var;
    -- password
    select new_password_param
    into password_var;
    -- password validation
    if length(password_var) < 8 
    then
	select concat('Password must be at least 8 characters long') into message;
	signal sqlstate 'HY000' set message_text = message;
	end if;
    
    -- No exceptions thrown, so update the username
    UPDATE `account_user`
	SET user_password = password_var
	WHERE user_id = user_id_var;

end //
delimiter ;

drop procedure if exists home_page;
DELIMITER //
create procedure home_page(userID int) 
begin
  -- home_page() needs to return a list of posts from all forums followed. alter
  Select * from post where (forum_id in (
  Select forum_id from follower where follower.user_id = userID) and post.archived = 0) order by forum_id, post_date DESC limit 20;
  
end//
DELIMITER ;

drop procedure if exists post_page;
DELIMITER //
create procedure post_page(postID int) 
begin

select * from post where parent_post_id = postID or post_id = postID  order by post_date desc limit 20;

end//
DELIMITER ;


drop procedure if exists user_page;
DELIMITER //
create procedure user_page(userID int) 
begin
	select * from post where userID = user_id order by post_date desc limit 10;
end//
DELIMITER ;

drop procedure if exists forum_page;
DELIMITER //
create procedure forum_page(forumID int, userID int) 
begin
	select * from post left join forum using (forum_id) left join (select * from post left join report using (post_id)) as reported using (user_id) where userID = user_id and forum_id = forumID order by post_date desc limit 20;

end//
DELIMITER ;

drop procedure if exists user_forum_posts;
DELIMITER //
create procedure user_forum_posts(forumID int, userID int) 
begin
	select * from post where forum_id = forumID and user_id = userID order by post_date desc limit 10;
end//
DELIMITER ;

select * from post;
