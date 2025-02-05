## How to Change Config Access Token

### 1. Generate a New Access Token

1. Go to your Git configuration repository provider, it might be either [git.verbis.dkfz.de](https://git.verbis.dkfz.de) or [gitlab.bbmri-eric.eu](https://gitlab.bbmri-eric.eu).  
2. Navigate to the configuration repository for your site.  
3. Go to **Settings → Access Tokens** to check if your Access Token is valid or expired.  
   - **If expired**, create a new Access Token.  
4. Configure the new Access Token with the following settings:  
   - **Expiration date**: One year from today, minus one day.  
   - **Role**: Developer.  
   - **Scope**: Only `read_repository`.  
5. Save the newly generated Access Token in a secure location.  

---

### 2. Replace the Old Access Token

1. Navigate to `/etc/bridgehead` in your system.  
2. Run the following command to retrieve the current Git remote URL:  
   ```bash
   git remote get-url origin
   ```
   Example output:  
   ```
   https://name40dkfz-heidelberg.de:<old_access_token>@git.verbis.dkfz.de/bbmri-bridgehead-configs/test.git
   ```
3. Replace `<old_access_token>` with your new Access Token in the URL.  
4. Set the updated URL using the following command:  
   ```bash
   git remote set-url origin https://name40dkfz-heidelberg.de:<new_access_token>@git.verbis.dkfz.de/bbmri-bridgehead-configs/test.git
   
   ```

5. Start the Bridgehead update service by running:  
   ```bash
   systemctl start bridgehead-update@<project>
   ```
6. View the output to ensure the update process is successful:  
   ```bash
   journalctl -u bridgehead-update@<project> -f
   ```