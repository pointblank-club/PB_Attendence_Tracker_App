from flask import Flask, jsonify, request
from dotenv import load_dotenv
from flask_cors import CORS
import json
import os
import smtplib
import qrcode
from io import BytesIO, StringIO
import base64
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
import uuid
import firebase_admin
from firebase_admin import credentials, firestore
from pymongo import MongoClient
import csv


app = Flask(__name__)
CORS(app)


cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)


db = firestore.client()
        

def get_participants_from_local_json(event_name):
   
    try:
        with open('participants.json', 'r') as f:
            registrations = json.load(f)
    except FileNotFoundError:
        print("Error: test_data.json not found.")
        return []

    standard_participants = []
    
    for reg in registrations:
        # We need to handle the '$oid' field from the sample data
        team_id = reg.get('_id', {}).get('$oid')

        def process_participant(p, participant_num):
            if not p or not p.get('email'):
                return None
            
            background = p.get('background', {})
            return {
                'participant_id': f"{team_id}_p{participant_num}",
                'team_id': team_id,
                'event_name': event_name,
                'participant_name': p.get('name'),
                'participant_email': p.get('email'),
                'age': p.get('age'),
                'gender': p.get('gender'),
                'phone': p.get('phone'),
                'experienceLevel': background.get('experienceLevel'),
                'previousParticipation': background.get('previousParticipation'),
                'participationDetails': background.get('participationDetails'),
                'affiliationType': background.get('affiliationType'),
                'affiliationName': background.get('affiliationName'),
            }

        p1_data = process_participant(reg.get('participant1'), 1)
        if p1_data:
            standard_participants.append(p1_data)

        if reg.get('participationType') == 'duo':
            p2_data = process_participant(reg.get('participant2'), 2)
            if p2_data:
                standard_participants.append(p2_data)
                
    return standard_participants

def get_ctf_participants_from_mongo(event_name):
    MONGO_URI = os.getenv('MONGO_URI')
    client = MongoClient(MONGO_URI)
    mongo_db = client.get_database('ctf_database_name')
    registrations_collection = mongo_db['ctfregs']

    standard_participants = []
    
    for reg in registrations_collection.find({}):
        team_id = str(reg.get('_id'))

        def process_participant(p, participant_num):
            if not p or not p.get('email'):
                return None
            
            background = p.get('background', {})
            return {
                'participant_id': f"{team_id}_p{participant_num}",
                'team_id': team_id,
                'event_name': event_name,
                
                # Participant Fields
                'participant_name': p.get('name'),
                'participant_email': p.get('email'),
                'age': p.get('age'),
                'gender': p.get('gender'),
                'phone': p.get('phone'),

                # Background Fields
                'experienceLevel': background.get('experienceLevel'),
                'previousParticipation': background.get('previousParticipation'),
                'participationDetails': background.get('participationDetails'),
                'affiliationType': background.get('affiliationType'),
                'affiliationName': background.get('affiliationName'),
            }

        # Process participant 1
        p1_data = process_participant(reg.get('participant1'), 1)
        if p1_data:
            standard_participants.append(p1_data)

        # Process participant 2 if it's a duo
        if reg.get('participationType') == 'duo':
            p2_data = process_participant(reg.get('participant2'), 2)
            if p2_data:
                standard_participants.append(p2_data)
                
    client.close()
    return standard_participants


def generate_qr_code(participant_data):
    try:
        
        json_data = json.dumps(participant_data)
        
       
        encoded_data = base64.b64encode(json_data.encode('utf-8')).decode('utf-8')
        
        
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(encoded_data)
        qr.make(fit=True)
        
        
        img = qr.make_image(fill_color="black", back_color="white")
        
        
        buffer = BytesIO()
        img.save(buffer, format="PNG")
        buffer.seek(0)
        
        return buffer.getvalue()
    except Exception as e:
        print(f"Error generating QR code: {e}")
        return None

# email settings
EMAIL_SERVER = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USER = os.getenv('EMAIL_USER')
EMAIL_PASSWORD = os.getenv('EMAIL_PASSWORD')
EMAIL_FROM = 'Blank <EMAIL_USER>'

def send_email(to_email, subject, body, participant_data=None):
    try:
        msg = MIMEMultipart('related')
        msg['Subject'] = subject
        msg['From'] = EMAIL_FROM
        msg['To'] = to_email

        qr_image = None
        html_body = f"""
        <html>
        <body>
            <p>Hello {participant_data.get('participant_name', '') if participant_data else ''},</p>
            <p>{body}</p>
        """

        if participant_data:
            qr_data = generate_qr_code(participant_data)
            if qr_data:
                qr_cid = str(uuid.uuid4())
                html_body += f"""
                <p>Here is your QR code for the event:</p>
                <img src="cid:{qr_cid}" width="300" height="300" />
                """
                qr_image = MIMEImage(qr_data)
                qr_image.add_header('Content-ID', f'<{qr_cid}>')

        html_body += """
            <p>Regards,<br>Event Team</p>
        </body>
        </html>
        """

        msg.attach(MIMEText(html_body, 'html'))

        if qr_image:
            msg.attach(qr_image)

        with smtplib.SMTP(EMAIL_SERVER, EMAIL_PORT) as server:
            server.starttls()
            server.login(EMAIL_USER, EMAIL_PASSWORD)
            server.send_message(msg)

        return True

    except Exception as e:
        print(f"Error sending email: {e}")
        return False

def send_confirmation_email(participant_name, to_email, event_name):
    try:
        msg = MIMEMultipart('related')
        msg['Subject'] = f"Attendance Confirmed: {event_name}"
        msg['From'] = EMAIL_FROM
        msg['To'] = to_email

        html_body = f"""
        <html>
        <body>
            <p>Hello {participant_name},</p>
            <p>This email confirms your successful check-in for the event: <b>{event_name}</b>.</p>
            <p>Thank you for participating!</p>
            <p>Regards,<br>Event Team</p>
        </body>
        </html>
        """
        msg.attach(MIMEText(html_body, 'html'))

        with smtplib.SMTP(EMAIL_SERVER, EMAIL_PORT) as server:
            server.starttls()
            server.login(EMAIL_USER, EMAIL_PASSWORD)
            server.send_message(msg)
        return True
    except Exception as e:
        print(f"Error sending confirmation email: {e}")
        return False


@app.route('/participants', methods=['GET'])
def get_participants():
    try:
        event_name = request.args.get('event', None)
        print(f"Fetching participants for event: {event_name}") 
        participants = get_participants_from_local_json(event_name)
        print(f"Found {len(participants)} participants")  
        
        return jsonify(participants)
        
    except Exception as e:
        print(f"Error in get_participants: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/events', methods=['GET'])
def get_events():
    
    try:
        events_ref = db.collection('events')
        events = events_ref.stream()
        
        event_list = []
        for event in events:
            event_list.append({
                'id': event.id,
                'name': event.id,
                'data': event.to_dict()
            })
        
        return jsonify(event_list)
        
    except Exception as e:
        print(f"Error fetching events: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/send-emails', methods=['POST'])
def send_emails_endpoint():
    try:
        data = request.json
        subject = data.get('subject', '')
        body = data.get('body', '')
        include_qr = data.get('include_qr', True)
        participants = data.get('participants', [])
        
        if not subject or not body or not participants:
            return jsonify({'success': False, 'message': 'Missing required fields'}), 400
        
        success_count = 0
        failure_count = 0
        
        for participant in participants:
            participant_data = participant if include_qr else None
            if send_email(participant['participant_email'], subject, body, participant_data):
                success_count += 1
            else:
                failure_count += 1
        
        return jsonify({
            'success': True,
            'message': f'Sent {success_count} emails, {failure_count} failed'
        })
    
    except Exception as e:
        return jsonify({'success': False, 'message': f'Error: {str(e)}'}), 500

@app.route('/mark-attendance', methods=['POST'])
def mark_attendance():
    try:
        # get the participant data from QR 
        data = request.json
        event_name = data.get('event_name')
        participant_id = data.get('participant_id')
        
        event_ref = db.collection('events').document(event_name)
        # saving attendance datat to firebase in a subcollection called attendees
        attendee_ref = db.collection('events').document(event_name).collection('attendees').document(participant_id)

        event_ref.set({
            'event_name': event_name,
            'last_activity': firestore.SERVER_TIMESTAMP
        }, merge=True)
        
        attendee_data = data.copy() 
        attendee_data['check_in_time'] = firestore.SERVER_TIMESTAMP 
        attendee_ref.set(attendee_data)
        
        
        send_confirmation_email(
            participant_name=data.get('participant_name'),
            to_email=data.get('participant_email'),
            event_name=event_name
        )
        
        
        return jsonify({'success': True, 'message': 'Attendance marked and confirmation sent.'})
        
    except Exception as e:
        print(f"Error marking attendance: {e}")
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/export-csv', methods=['GET'])
def export_csv():
    
    event_name = request.args.get('event')
    if not event_name:
        return jsonify({'error': 'Event name is required'}), 400

    try:
        # Reference the 'attendees' subcollection in your Firebase
        attendees_ref = db.collection('events').document(event_name).collection('attendees')
        docs = attendees_ref.stream()

        # StringIO to create a CSV file in memory
        output = StringIO()
        writer = csv.writer(output)

        # header row
        writer.writerow([
            'Participant ID', 'Team ID', 'Name', 'Email', 'Age', 'Gender', 'Phone',
            'Experience Level', 'Previously Participated', 'Participation Details',
            'Affiliation Type', 'Affiliation Name', 'Check-in Time'
        ])

        # rows for each attendee
        for doc in docs:
            data = doc.to_dict()
            check_in_time = data.get('check_in_time')
            formatted_time = check_in_time.strftime('%Y-%m-%d %H:%M:%S') if check_in_time else 'N/A'

            writer.writerow([
                data.get('participant_id', ''),
                data.get('team_id', ''),
                data.get('participant_name', ''),
                data.get('participant_email', ''),
                data.get('age', ''),
                data.get('gender', ''),
                data.get('phone', ''),
                data.get('experienceLevel', ''),
                data.get('previousParticipation', ''),
                data.get('participationDetails', ''),
                data.get('affiliationType', ''),
                data.get('affiliationName', ''),
                formatted_time
            ])

       
        csv_output = output.getvalue()
        output.close()

        
        return csv_output, 200, {
            'Content-Type': 'text/csv',
            'Content-Disposition': f'attachment; filename="{event_name}_attendance.csv"'
        }

    except Exception as e:
        print(f"Error generating CSV: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/test', methods=['GET'])
def test_endpoint():
    return jsonify({'message': 'Server is running!', 'status': 'OK'})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)