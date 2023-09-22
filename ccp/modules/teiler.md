# Teiler
This module orchestrates the different microfrontends of the bridgehead as a single page application.  

## Teiler Orchestrator
Single SPA component that consists on the root HTML site of the single page application and a javascript code that
gets the information about the microfrontend calling the teiler backend and is responsible for registering them. With the
resulting mapping, it can initialize, mount and unmount the required microfrontends on the fly. 

The microfrontends run independently in different containers and can be based on different frameworks (Angular, Vue, React,...)
This microfrontends can run as single alone but need an extension with Single-SPA (https://single-spa.js.org/docs/ecosystem).
There are also available three templates (Angular, Vue, React) to be directly extended to be used directly in the teiler.

## Teiler Dashboard
It consists on the main dashboard and a set of embedded services.
### Login
user and password in ccp.local.conf

## Teiler Backend
In this component, the microfrontends are configured.
