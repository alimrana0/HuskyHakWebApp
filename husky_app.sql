drop database if exists husky_app;

create database husky_app;
use husky_app;


-- a user
drop table if exists account_user;
create table account_user(
	user_id INT NOT NULL PRIMARY KEY auto_increment, 
    user_name VARCHAR(20) NOT NULL,
    user_email VARCHAR(45) NOT NULL,
    user_reg_date DATE NOT NULL,
    user_password VARCHAR(45) NOT NULL
);

INSERT into `account_user` values (9999, "anu", "anu@email", "1998-12-12", "1234");
INSERT into `account_user` values (9998, "noah", "noah@email", "2020-05-12", "5678"); 
INSERT into `account_user` values (9997, "manvi", "manvi@email", "2020-05-05", "1122");
INSERT into `account_user` values (9996, "ali", "ali@email", "2021-10-4", "7766");
INSERT into `account_user` values (9995, "jim", "jim@email", "2020-2-14", "1001");
INSERT into `account_user` values (9994, "jane", "jane@email","2020-06-12", "57653"); 
INSERT into `account_user` values (9993, "joe", "joe@email", "2020-07-05", "112223232");
INSERT into `account_user` values (9992, "billy", "billy@email", "2020-03-10", "7763236");

select * from account_user;
-- LOAD DATA INFILE '/Users/anu_k18/Northeastern University/CS3200 Database Design/Final Project' INTO TABLE account_user FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;



drop table if exists forum;
create table forum(
    forum_id INT NOT NULL PRIMARY KEY auto_increment,
    forum_name VARCHAR(30) NOT NULL
);

insert into forum values
(1, 'test');

select * from account_user;
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Forum_Names_DD.csv' INTO TABLE forum FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;


drop table if exists post;
create table post(
    post_id INT NOT NULL PRIMARY KEY auto_increment,
    user_id INT NOT NULL,
    forum_id INT NOT NULL,
    parent_post_id INT,
    post_date DATE NOT NULL,
    archived tinyint not null,
    title VARCHAR(100) NOT NULL,
    contents VARCHAR(500),
    FOREIGN KEY(forum_id) REFERENCES forum(forum_id),
    FOREIGN KEY(parent_post_id) REFERENCES post(post_id),
    FOREIGN KEY(user_id) REFERENCES account_user(user_id)
);

insert into post (user_id, forum_id,parent_post_id, post_date, archived, title, contents) values
(9998, 1, null, curDate(), False, 'hey', 'heyy');

SET FOREIGN_KEY_CHECKS = 0;
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Posts_DD.csv' INTO TABLE post FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
SET FOREIGN_KEY_CHECKS = 1;

SELECT * from post;

drop table if exists permissions;
create table permissions(
    permissions_id INT NOT NULL PRIMARY KEY auto_increment,
    can_ban TINYINT NOT NULL,
    prioritized_post TINYINT NOT NULL
);

-- moderator.
insert into permissions values (1, 1, 0);


drop table if exists rating;
create table rating(
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    pos_neg TINYINT NOT NULL
);

drop table if exists badge;
create table badge(
     badge_id INT NOT NULL PRIMARY KEY auto_increment,
     badge_name VARCHAR(45) NOT NULL,
     badge_image BLOB,
     permissions_id INT,
     user_id INT,
     FOREIGN KEY (user_id) references account_user(user_id),
     FOREIGN KEY (permissions_id) references permissions(permissions_id)
);

insert into badge (badge_id, badge_name) values (1, "1-Year Veteran");
insert into badge (badge_id, badge_name, permissions_id) values (2, "Moderator", 1);

drop table if exists report;
create table report(
    report_id INT NOT NULL PRIMARY KEY auto_increment, 
    comment VARCHAR(200),
    report_date date NOT NULL,
    post_id INT NOT NULL,
    -- make sure to add data validation here; need to make sure that user_id is same as in post_id.
    FOREIGN KEY (post_id) references post(post_id)
);

drop table if exists follower;
create table follower(
    forum_id INT NOT NULL,
    user_id INT NOT NULL,
    follow_date DATE NOT NULL,
    FOREIGN KEY(forum_id) references forum(forum_id),
    FOREIGN KEY(user_id) REFERENCES account_user(user_id)
);


SET FOREIGN_KEY_CHECKS = 0;
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Followings_DD.csv' INTO TABLE follower FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
SET FOREIGN_KEY_CHECKS = 1;
select * from follower;

drop table if exists ban;
create table ban(
	ban_id INT NOT NULL PRIMARY KEY,
    report_id INT NOT NULL,
    FOREIGN KEY(report_id) references report(report_id)
);

drop table if exists forum_rank;
create table forum_rank(
    user_id INT NOT NULL,
    badge_id INT NOT NULL,
    forum_id INT NOT NULL,
    
    FOREIGN KEY(user_id) REFERENCES account_user(user_id),
    FOREIGN KEY(badge_id) REFERENCES badge(badge_id),
    FOREIGN KEY(forum_id) REFERENCES forum(forum_id)
);

select * from forum;
select * from post;