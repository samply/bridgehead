# Teiler

**Teiler** is the central frontend of the **bridgehead system**. It brings together multiple independent tools—each built as a **microfrontend**—into a single, unified web application.

Users interact with Teiler as one coherent interface, but behind the scenes, it dynamically integrates and displays self-contained modules developed with different technologies (**Angular**, **Vue**, **React**, etc.). This modular approach makes Teiler highly flexible, allowing teams to develop, deploy, and maintain features independently.

Teiler ensures:

* **A consistent look and feel** across tools.
* **Smooth navigation** between components.
* **Seamless user authentication** across the entire interface.

Each independent tool integrated into Teiler is called a **bridgehead app**. A bridgehead app can be:

- A fully standalone microfrontend with its own frontend and backend services.
- An embedded service inside the Teiler Dashboard.
- An external link to another service, possibly hosted on a central server or elsewhere in the federated research network.

The modularity of Teiler enables it to adapt easily to the evolving needs of the research federated network by simply adding, updating, or removing bridgehead apps.

Below is a breakdown of Teiler's internal components that make this orchestration possible.

- [Teiler Orchestrator](#teiler-orchestrator)  
- [Teiler Dashboard](#teiler-dashboard)  
- [Teiler Backend](#teiler-backend)

---

## Teiler Orchestrator
  
**GitHub repository:** [https://github.com/samply/teiler-orchestrator](https://github.com/samply/teiler-orchestrator)  
  
The **Teiler Orchestrator** is the entry point of the **Single Page Application (SPA)**. It consists of:

- An **HTML root page**.
- A **JavaScript layer** that:
  - **Retrieves microfrontend configurations** from the backend.
  - **Registers and manages** the microfrontends using [**Single-SPA**](https://single-spa.js.org/), the framework Teiler uses to create and coordinate its microfrontend environment.

Using this information, the orchestrator dynamically **loads the correct microfrontend** for a given route and manages its **lifecycle** (*init*, *mount*, *unmount*) in real time.

**Microfrontends** run in their own containers and can be implemented with any major frontend framework. To be compatible with Teiler, they must integrate with **Single-SPA**.

To encourage developers to create their own microfrontends and integrate them into Teiler, we provide **starter templates** for **Angular**, **Vue**, and **React**. Developing a new microfrontend is straightforward:

1. Use one of the templates.
2. Extend it with your own functionality.
3. Add its configuration in the **Teiler Backend**.

This modular approach accelerates development and fosters collaboration.


---

## Teiler Dashboard
  
**GitHub repository:** [https://github.com/samply/teiler-dashboard](https://github.com/samply/teiler-dashboard)  
  
The **Teiler Dashboard** is the unified interface users interact with after logging in. It provides:

- A **single point of access** where various bridgehead apps are embedded as microfrontends.
- **Central navigation** and **session management** for a smooth user experience.

### Authentication and Authorization

Teiler uses **OpenID Connect (OIDC)** for user authentication, accessible via the **top navigation bar**.

We consider three possible **application roles**:

| Role   | Description                                               |
|--------|-----------------------------------------------------------|
| Public | Accessible by any user without the need to log in         |
| User   | Normal users working with various bridgehead applications |
| Admin  | Bridgehead system administrators                           |

It is possible to **deactivate OIDC authentication** entirely. In such cases, **all apps must have at least the public role** to allow access. While this may be suitable for development or testing, we **strongly encourage** at least some external authentication mechanism or network-level access control to secure the bridgehead environment.

Alternatively, basic authentication can be enforced through the existing **Traefik infrastructure** integrated with the bridgehead.

---

## Teiler Backend

**GitHub repository:** [https://github.com/samply/teiler-backend](https://github.com/samply/teiler-backend)  
  
The **Teiler Backend** serves as the central configuration hub for all microfrontends and bridgehead apps. It defines:

- Which bridgehead apps are available.
- Their loading URLs and routes.
- Optional metadata such as display names, icons, roles, and activation status.

It enables the orchestrator to remain **generic and flexible**, adapting dynamically to whatever apps are defined in the backend configuration.

### Assets Directory

There is an **assets** directory where you can save images and other static files to be accessible to your microfrontends. This helps configure and customize apps more easily and quickly.

Assets can be referenced via:

```
<Teiler Backend URL>/assets/<filename>
```

### App Configuration via Environment Variables

Apps are configured using environment variables with the following structure:

```
TEILER_APP<Number>_<suffix>
Optional: TEILER_APP<Number>_<LanguageCode>_<suffix>
```

- The **number** is just for grouping variables for a single app and has no intrinsic meaning.
- The **app** is the unit within Teiler, shown as a box in the dashboard.
- Apps can be:
  - Embedded apps inside the Teiler Dashboard (there is a helper Python script for generating embedded apps: [create-embedded-app.py](https://github.com/samply/teiler-dashboard/blob/main/create-embedded-app.py))
  - External links (e.g., central services outside the local bridgehead instance)
- An app's frontend (microfrontend or embedded app) can either contain the entire functionality or serve as a frontend communicating with other backend microservices in the bridgehead.

Currently supported languages in the main projects DKTK and BBMRI are **English (EN)** and **German (DE)**, but the system can be extended to other languages.  
  
The Teiler Dashboard requests variables from the backend for each app and passes the desired language code. If a language-specific variable is unavailable, the default language value is returned.

### Internationalization (i18n)
#### ⚠️ Important

If you make any changes to the **Teiler Dashboard**, and those changes involve text elements (e.g., labels, buttons, messages), you must also update the **English translations**, since the application uses **internationalization (i18n)**.

The **default language** of the project is **German**, so any new text must be manually translated into English after extracting the updated i18n entries.

To extract new translation entries, run the following command:

```bash
ng extract-i18n --output-path src/i18n --format=xlf2
````

This will generate or update the file:
`src/i18n/messages.xlf`

---

#### ✅ Requirements to Run the Extraction Command

| Program                          | Purpose                                        | Linux Shell (Ubuntu/Debian)                                                                                                                     | Windows PowerShell                                                  |
| -------------------------------- | ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **Node.js**                      | JavaScript runtime required by Angular and npm | `sudo apt update && sudo apt install nodejs npm`<br>**or**<br>[Use NodeSource setup](https://github.com/nodesource/distributions) (recommended) | [Download from nodejs.org](https://nodejs.org) and install manually |
| **npm**                          | Node package manager (comes with Node.js)      | *(Included with Node.js)*                                                                                                                       | *(Included with Node.js)*                                           |
| **Angular CLI**                  | Command-line interface for Angular tooling     | `npm install -g @angular/cli`                                                                                                                   | `npm install -g @angular/cli`                                       |
| **Angular project dependencies** | Required packages from `package.json`          | `npm install`                                                                                                                                   | `npm install`                                                       |

---

#### ✏️ Updating the English Translation

After running the extraction command, the file `src/i18n/messages.xlf` will contain any newly added i18n entries.

To provide English translations:

1. Open `src/i18n/messages.en.xlf`.
2. Compare it with the updated `messages.xlf` to identify any new entries.
3. Copy the new `<trans-unit>` blocks from `messages.xlf` into `messages.en.xlf`.
4. For each entry, add the English translation inside the `<target>` tag (in `messages.en.xlf`):

   ```xml
   <trans-unit id="..." datatype="html">
     <source>Willkommen</source>
     <target>Welcome</target>
   </trans-unit>
   ```

### App Availability Monitoring

The Teiler Backend regularly **pings apps** to check availability and displays status messages such as:

- "Frontend not available"
- "Backend not available"
- "Frontend and Backend not available"

### Accepted TEILER_APP Variable Suffixes

| Suffix           | Description                                                                                                   |
|------------------|---------------------------------------------------------------------------------------------------------------|
| NAME             | Identifier of the app (no spaces). For embedded apps, must match the identifier defined in Teiler Dashboard.  |
| TITLE            | Display title shown to users.                                                                                  |
| DESCRIPTION      | Brief description of the app.                                                                                   |
| BACKENDURL       | URL of the backend microservice (if applicable).                                                              |
| BACKENDCHECKURL  | URL that the backend pings to verify backend availability. Defaults to BACKENDURL if not specified.             |
| SOURCEURL        | URL of the microfrontend or external link (not used for embedded apps).                                        |
| SOURCECHECKURL   | URL to ping to check microfrontend or external link availability. Defaults to SOURCEURL if not specified.       |
| ROLES            | Comma-separated roles allowed: `TEILER_PUBLIC`, `TEILER_USER`, `TEILER_ADMIN`.                                 |
| ISACTIVATED      | `true` or `false`. Used to temporarily deactivate an app without deleting its config.                           |
| ICONCLASS        | Bootstrap icon class to display in app box (e.g., `"bi bi-search"`).                                           |
| ICONSOURCEURL    | URL to an image icon. Prefer using local assets instead of external URLs.                                       |
| ORDER            | Relative display order of the app in the dashboard.                                                            |
| ISEXTERNALLINK   | `true` or `false`. Indicates if the app is an external link outside the local bridgehead.                       |
| ISLOCAL          | `true` or `false`. Indicates if the app runs locally within the bridgehead site or on a central server.         |

*Note:* Embedded apps often have many of these variables preconfigured and may not require manual specification. See the [Teiler Dashboard documentation](https://github.com/samply/teiler-dashboard) for details.

### Additional Teiler Backend Variables for Dashboard Configuration

| Variable Prefix                    | Description                                                                                                  |
|------------------------------------|--------------------------------------------------------------------------------------------------------------|
| TEILER_DASHBOARD_                  | General configuration of the dashboard.                                                                     |
| TEILER_DASHBOARD_&lt;LangCode&gt;_ | Language-specific configuration overrides.                                                                   |

Important suffixes include:

| Suffix           | Description                                                                               |
|------------------|-------------------------------------------------------------------------------------------|
| WELCOME_TITLE    | Title shown on the initial screen before login.                                           |
| WELCOME_TEXT     | Welcome message or instructions before login.                                             |
| FURTHER_INFO     | Additional informational text or links.                                                   |
| BACKGROUND_IMAGE_URL | URL to a background image (SVG recommended for scalability).                              |
| LOGO_URL         | URL to the project or bridgehead logo.                                                    |
| LOGO_HEIGHT      | Height of the displayed logo.                                                             |
| LOGO_TEXT        | Title text of the bridgehead (e.g., "DKTK Bridgehead").                                   |
| COLOR_PALETTE    | JSON link to color palettes for text, lines, icons, and background (especially for SVGs). |
| COLOR_PROFILE    | Selected color profile from the palette. (color palette name)                             |
| FONT             | Font family for the dashboard text.                                                       |

### 🎨 Color Palette

Below is an example of a **color palette** definition in JSON format:

```json
{
  "color-palettes": [
    {
      "name": "Grey",
      "colors": {
        "text": "grey",
        "line": "grey",
        "icon": "grey",
        "background": "grey"
      }
    },
    {
      "name": "Black",
      "colors": {
        "text": "black",
        "line": "black",
        "icon": "black",
        "background": "#F7ADAD"
      }
    }
  ]
}
```

Each palette contains a unique `name` and a set of color values for different UI elements.

#### 🔍 Palette Elements

| **Variable** | **Description**                                     |
| ------------ | --------------------------------------------------- |
| `name`       | Identifier of the color palette                     |
| `text`       | Color used for text                                 |
| `line`       | Color used for lines (e.g., borders, dividers)      |
| `icon`       | Color used for icons                                |
| `background` | Background color (especially useful for SVG images) |


---

### 🚀 Ready to Extend Teiler?

If you want to create your own **bridgehead app** and integrate it into **Teiler**, start by:

1. Selecting a template **or**
2. Building a microfrontend compatible with [Single-SPA](https://single-spa.js.org/).

Then, register your app’s configuration in the **Teiler Backend** as described above.

> 💡 **Tip:** This flexible, modular design makes it easy to plug in your own features and services.

---

### 🔧 Build & Contribute Your App!

🧩 **Join the ecosystem!**
Add your app to Teiler and expand its functionality for everyone.

Whether it’s a visualization tool, a data processing module, or a custom UI component — your contribution can help grow the platform. 💪

> 👉 **Get started today and shape the future of Teiler!**

