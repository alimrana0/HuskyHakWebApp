from flask import Flask, render_template, request, redirect, url_for, session
from flask_mysqldb import MySQL
import MySQLdb.cursors
import re



app = Flask(__name__)

app.secret_key = 'your secret key'

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '*********'
app.config['MYSQL_DB'] = 'husky_app'

mysql = MySQL(app)


@app.route('/')
@app.route('/login', methods=['GET', 'POST'])
def login():
    msg = ''
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        username = request.form['username']
        password = request.form['password']
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute('SELECT * FROM account_user WHERE user_name = % s AND user_password = % s',
                       (username, password,))
        account = cursor.fetchone()
        if account:
            session['loggedin'] = True
            session['user_id'] = account['user_id']
            session['username'] = account['user_name']
            msg = 'Logged in successfully !'
            return render_template('index.html', msg=msg)
        else:
            msg = 'Incorrect username / password !'
    return render_template('login.html', msg=msg)


@app.route('/forum')
def forum():
    return render_template('Forum.html')

@app.route('/index')
def index():
    return render_template('index.html')




@app.route('/logout')
def logout():
    session.pop('loggedin', None)
    session.pop('id', None)
    session.pop('username', None)
    return redirect(url_for('login'))

@app.route('/forum', methods=['GET', 'POST'])
def make_post():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    post = request.form['post']
    user_id = session['user_id']
    forum_id = 1
    title = request.form['title']
    cursor.callproc('add_post', args = (post, title, user_id, forum_id))
    # save contents and get the post_id
    mysql.connection.commit()
    return render_template('forum.html')

    # need a 'report' button on a post, red flag?
@app.route('/forum', methods=['GET', 'POST'])
def report_post():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    post = request.form['post']
    cursor.callproc('report_post', args = (post))


# @app.route('/forum', methods = ['GET', 'POST'])
# def add_comment():
#     cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
#     comment =


@app.route('/register', methods=['GET', 'POST'])
def register():
    msg = ''
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form and 'email' in request.form:
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.callproc('register_user', args=(email, username, password))
        #how to save contents of callproc, output an error messgae rather than breaking the whole thing
        mysql.connection.commit()
        return render_template('index.html')
    return render_template('register.html', msg=msg)


@app.route('/makeforum')
def homeforum():
    return render_template('makeforum.html')

@app.route('/makeforum', methods=['GET', 'POST'])
def make_forum():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    name = request.form['name']
    cursor.callproc('add_forum', args =[name])
    # save contents and get the post_id
    mysql.connection.commit()
    return render_template('forum.html')

@app.route('/homeforum', methods=['GET', 'POST'])
def view_forums():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.callproc('getForums')
    data = [item['forum_name'] for item in cursor.fetchall()]
    cursor.close()
    return render_template('homeforum.html', data=data)

@app.route('/viewPosts', methods=['GET', 'POST'])
def viewPosts():
   # forumName = request.form.get('Val')
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    forumName = request.form['Val']
    cursor.callproc('getPosts2', args =[forumName])
    
    row = cursor.fetchone()
    cursor.close() 
    # cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor) 
    # cursor.callproc('getPosts', forumID)
    # titleData = [item['title'] for item in cursor.fetchall()]
    # contentsData = [item['contents'] for item in cursor.fetchall()]
    return render_template('forumposts.html', forumID = row)


app.run(debug=True)

