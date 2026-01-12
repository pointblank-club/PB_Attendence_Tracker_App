import json
import firebase_admin
from firebase_admin import credentials, firestore

SERVICE_ACCOUNT_KEY_FILE = "serviceAccountKey.json"
PARTICIPANTS_JSON_FILE = "participants.json"

try:
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_FILE)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
except Exception as e:
    print(f"Error initializing Firestore: {e}")
    exit()

try:
    with open(PARTICIPANTS_JSON_FILE, 'r') as f:
        participants = json.load(f)
except Exception as e:
    print(f"Error loading {PARTICIPANTS_JSON_FILE}: {e}")
    exit()

events = {}
for p in participants:
    event_name = p.get("event_name")
    if event_name:
        if event_name not in events:
            events[event_name] = []
        events[event_name].append(p)

for event_name, participants_list in events.items():
    print(f"Processing event: '{event_name}'")
    event_ref = db.collection('events').document(event_name)
    event_ref.set({'name': event_name}, merge=True)
    
    for participant in participants_list:
        participant_id = participant.get("participant_id")
        if participant_id:
            participant_ref = event_ref.collection('participants').document(participant_id)
            participant_ref.set(participant)

print("Upload complete.")