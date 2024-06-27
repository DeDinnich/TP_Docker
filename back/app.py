from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
import os
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

CORS(app, resources={r"/api/*": {"origins": "*"}})

# Configuration de la connexion à la base de données
db_user = os.getenv('DB_USER', 'guestuser')
db_password = os.getenv('DB_PASSWORD', 'guestpassword')
db_host = os.getenv('DB_HOST', 'mariadb-server')
db_name = os.getenv('DB_NAME', 'guestbook')

app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+pymysql://{db_user}:{db_password}@{db_host}/{db_name}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class Message(db.Model):
    __tablename__ = 'messages'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    message = db.Column(db.String(1024), nullable=False)

@app.route('/api/messages', methods=['GET'])
def get_messages():
    messages = Message.query.all()
    return jsonify([{'name': msg.name, 'message': msg.message} for msg in messages])

@app.route('/api/messages', methods=['POST'])
def post_message():
    name = request.json['name']
    message = request.json['message']
    new_message = Message(name=name, message=message)
    db.session.add(new_message)
    db.session.commit()
    return jsonify({'name': name, 'message': message}), 201

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
