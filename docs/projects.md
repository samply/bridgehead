## Projects

### GBA/BBMRI-ERIC

The **Sample Locator** is a tool that allows researchers to make searches for samples over a large number of geographically distributed biobanks. Each biobank runs a so-called **Bridgehead** at its site, which makes it visible to the Sample Locator.  The Bridgehead is designed to give a high degree of protection to patient data. Additionally, a tool called the [Negotiator][negotiator] puts you in complete control over which samples and which data are delivered to which researcher.

You will most likely want to make your biobanks visible via the [publicly accessible Sample Locator][sl], but the possibility also exists to install your own Sample Locator for your site or organization, see the GitHub pages for [the server][sl-server-src] and [the GUI][sl-ui-src].

The Bridgehead has two primary components:
* The **Blaze Store**. This is a highly responsive FHIR data store, which you will need to fill with your data via an ETL chain.
* The **Connector**. This is the communication portal to the Sample Locator, with specially designed features that make it possible to run it behind a corporate firewall without making any compromises on security.

#### Register with a Directory

The [Directory][directory] is a BBMRI project that aims to catalog all biobanks in Europe and beyond. Each biobank is given its own unique ID and the Directory maintains counts of the number of donors and the number of samples held at each biobank. You are strongly encouraged to register with the Directory, because this opens the door to further services, such as the [Negotiator][negotiator].

Generally, you should register with the BBMRI national node for the country where your biobank is based. You can find a list of contacts for the national nodes [here](http://www.bbmri-eric.eu/national-nodes/). If your country is not in this list, or you have any questions, please contact the [BBMRI helpdesk](mailto:directory@helpdesk.bbmri-eric.eu). If your biobank is for COVID samples, you can also take advantage of an accelerated registration process [here](https://docs.google.com/forms/d/e/1FAIpQLSdIFfxADikGUf1GA0M16J0HQfc2NHJ55M_E47TXahju5BlFIQ).

Your national node will give you detailed instructions for registering, but for your information, here are the basic steps:

* Log in to the Directory for your country.
* Add your biobank and enter its details, including contact information for a person involved in running the biobank.
* You will need to create at least one collection.
* Note the biobank ID and the collection ID that you have created - these will be needed when you register with the Locator (see below).

#### Register with a Locator

* Go to the registration page http://localhost:8082/admin/broker_list.xhtml.
* To register with a Locator, enter the following values in the three fields under "Join new Searchbroker":
  * "Address": Depends on which Locator you want to register with:
    * `https://locator.bbmri-eric.eu/broker/`: BBMRI Locator production service (European).
    * `http://147.251.124.125:8088/broker/`: BBMRI Locator test service (European).
    * `https://samplelocator.bbmri.de/broker/`: GBA Sample Locator production service (German).
    * `https://samplelocator.test.bbmri.de/broker/`: GBA Sample Locator test service (German).
  * "Your email address": this is the email to which the registration token will be returned.
  * "Automatic reply": Set this to be `Total Size`
* Click "Join" to start the registration process.
* You should now have a list containing exactly one broker. You will notice that the "Status" box is empty.
* Send an email to `feedback@germanbiobanknode.de` and let us know which of our Sample Locators you would like to register to. Please include the biobank ID and the collection ID from your Directory registration, if you have these available.
* We will send you a registration token per email.
* You will then re-open the Connector and enter the token into the "Status" box.
* You should send us an email to let us know that you have done this.
* We will then complete the registration process
* We will email you to let you know that your biobank is now visible in the Sample Locator.

If you are a Sample Locator administrator, you will need to understand the [registration process](./SampleLocatorRegistration.md). Normal bridgehead admins do not need to worry about this.

TODO: 
- [ ] How to transfer from gbn

### CCP(DKTK/C4)

TODO: 
- [ ] How to transfer from windows

### nNGM

TODO:

