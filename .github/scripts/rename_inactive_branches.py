import os
import requests
from datetime import datetime, timedelta

# Configuration
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
REPO = 'samply/bridgehead'
HEADERS = {'Authorization': f'token {GITHUB_TOKEN}', 'Accept': 'application/vnd.github.v3+json'}
API_URL = f'https://api.github.com/repos/{REPO}/branches'
INACTIVE_DAYS = 365
CUTOFF_DATE = datetime.now() - timedelta(days=INACTIVE_DAYS)

# Fetch all branches
def get_branches():
    response = requests.get(API_URL, headers=HEADERS)
    return response.json() if response.status_code == 200 else []

# Rename inactive branches
def rename_branch(old_name, new_name):
    rename_url = f'https://api.github.com/repos/{REPO}/branches/{old_name}/rename'
    response = requests.post(rename_url, json={'new_name': new_name}, headers=HEADERS)
    print(f"Renamed branch {old_name} to {new_name}" if response.status_code == 201 else f"Failed to rename {old_name}: {response.status_code}")

# Check if the branch is inactive
def is_inactive(commit_url):
    last_commit_date = requests.get(commit_url, headers=HEADERS).json()['commit']['committer']['date']
    return datetime.strptime(last_commit_date, '%Y-%m-%dT%H:%M:%SZ') < CUTOFF_DATE

# Rename inactive branches
for branch in get_branches():
    if is_inactive(branch['commit']['url']):
        #rename_branch(branch['name'], f"archived/{branch['name']}")
        print(f"[LOG] Branch '{branch['name']}' is inactive and would be renamed to 'archived/{branch['name']}'")