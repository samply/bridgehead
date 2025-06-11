# Teiler

**Teiler** is the central frontend of the **bridgehead system**. It brings together multiple independent tools—each built as a **microfrontend**—into a single, unified web application.

Users interact with Teiler as one coherent interface, but behind the scenes, it dynamically integrates and displays self-contained modules developed with different technologies (**Angular**, **Vue**, **React**, etc.). This modular approach makes Teiler highly flexible, allowing teams to develop, deploy, and maintain features independently.

Teiler ensures:

* **A consistent look and feel** across tools.
* **Smooth navigation** between components.
* **Seamless user authentication** across the entire interface.

Below is a breakdown of Teiler's internal components that make this orchestration possible.

---

## Teiler Orchestrator

The **Teiler Orchestrator** is the entry point of the **Single Page Application (SPA)**. It consists of:

- An **HTML root page**.
- A **JavaScript layer** that:
    - **Retrieves microfrontend configurations** from the backend.
    - **Registers and manages** them using [**Single-SPA**](https://single-spa.js.org/).

Using this information, it dynamically **loads the correct microfrontend** for a given route and manages its **lifecycle** (*init*, *mount*, *unmount*) in real time.

**Microfrontends** run in their own containers and can be implemented with any major frontend framework. To be compatible with Teiler, they must integrate with **Single-SPA**.

To ease integration, Teiler offers **starter templates** for **Angular**, **Vue**, and **React**.

---

## Teiler Dashboard

The **Teiler Dashboard** is what users see after logging in. It provides:

- A **unified interface** where various services are embedded as microfrontends.
- **Central navigation** and **session management**.

### Authentication

Teiler uses **OpenID Connect (OIDC)** for authentication.

Users log in via the **top navigation bar**.

---

## Teiler Backend

The **Teiler Backend** is responsible for **storing and serving the configuration** of the available microfrontends. It defines:

- **Which microfrontends are available**
- Their **loading URLs and routes**
- Optional metadata such as **display names** or **icons**

This enables the orchestrator to remain **generic and flexible**, adapting dynamically to whatever microfrontends are defined in the backend configuration.
