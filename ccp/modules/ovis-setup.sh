#!/bin/bash -e

if [ -n "$ENABLE_OVIS" ];then
    # Setup MongoDB initialization directory if it doesn't exist
    mkdir -p "/var/cache/bridgehead/ccp/ovis/mongo/init"
    
    # Generate MongoDB initialization script directly
    cat > "/var/cache/bridgehead/ccp/ovis/mongo/init/init.js" << 'EOF'
db = db.getSiblingDB("test_credos");
db.createCollection("user");
db.user.insertMany([{
    "_id": "OVIS-Root",
    "createdAt": new Date(),
    "createdBy": "system",
    "role": "super-admin",
    "status": "active",
    "pseudonymization": false,
    "darkMode": false,
    "colorTheme": "CCCMunich",
    "language":  "de",
}]);

db = db.getSiblingDB("onc_test");
db.createCollection("user");
db.user.insertMany([{
    "_id": "OVIS-Root",
    "createdAt": new Date(),
    "createdBy": "system",
    "role": "super-admin",
    "status": "active",
    "pseudonymization": false,
    "darkMode": false,
    "colorTheme": "CCCMunich",
    "language":  "de",
}]);

db.ops.insertMany([
    {"OPSC_4":"1-40","OPS_Gruppen_Text":"Biopsie ohne Inzision an Nervensystem und endokrinen Organen "},
    {"OPSC_4":"1-44","OPS_Gruppen_Text":"Biopsie ohne Inzision an den Verdauungsorganen"},
    {"OPSC_4":"1-40","OPS_Gruppen_Text":"Biopsie ohne Inzision an anderen Organen und Geweben"},
    {"OPSC_4":"1-50","OPS_Gruppen_Text":"Biopsie an Haut, Mamma, Knochen und Muskeln durch Inzision"},
    {"OPSC_4":"1-51","OPS_Gruppen_Text":"Biopsie an Nervengewebe, Hypophyse, Corpus pineale durch Inzision und Trepanation von Schädelknochen "},
    {"OPSC_4":"1-55","OPS_Gruppen_Text":"Biopsie an anderen Verdauungsorganen, Zwerchfell und (Retro-)Peritoneum durch Inzision "},
    {"OPSC_4":"1-56","OPS_Gruppen_Text":"Biopsie an Harnwegen und männlichen Geschlechtsorgannen durch Inzision"},
    {"OPSC_4":"1-58","OPS_Gruppen_Text":"Biopsie an anderen Organen durch Inzision "},
    {"OPSC_4":"1-63","OPS_Gruppen_Text":"Diagnostische Endoskopie des oberen Verdauungstraktes"},
    {"OPSC_4":"1-65","OPS_Gruppen_Text":"Diagnostische Endoskopie des unteren Verdauungstraktes"},
    {"OPSC_4":"1-69","OPS_Gruppen_Text":"Diagnostische Endoskopie durch Inzision und intraoperativ "},
    {"OPSC_4":"5-01","OPS_Gruppen_Text":"Inzision (Trepanation) und Exzision an Schädel, Gehirn und Hirnhäuten"},
    {"OPSC_4":"5-02","OPS_Gruppen_Text":"Andere Operationen  an Schädel, Gehirn und Hirnhäuten"},
    {"OPSC_4":"5-03","OPS_Gruppen_Text":"Operationen an Rückenmark, Rückenmarkhäuten und Spinalkanal"},
    {"OPSC_4":"5-05","OPS_Gruppen_Text":"Andere Operationen an Nerven und Nervenganglien "},
    {"OPSC_4":"5-06","OPS_Gruppen_Text":"Operationen an Schilddrüse und Nebenschilddrüse "},
    {"OPSC_4":"5-07","OPS_Gruppen_Text":"Operationen an anderen endokrinen Drüsen "},
    {"OPSC_4":"5-20","OPS_Gruppen_Text":"Andere Operationen an Mittel- und Innenohr "},
    {"OPSC_4":"5-25","OPS_Gruppen_Text":"Operationen an der Zunge "},
    {"OPSC_4":"5-31","OPS_Gruppen_Text":"Andere Larynxoperationen und Operationen an der Trachea "},
    {"OPSC_4":"5-32","OPS_Gruppen_Text":"Exzision und Resektion an Lunge und Bronchus "},
    {"OPSC_4":"5-33","OPS_Gruppen_Text":"Andere Operationen an Lunge und Bronchus"},
    {"OPSC_4":"5-34","OPS_Gruppen_Text":"Operationen an Brustwand, Pleura, Mediastinum und Zwerchfell "},
    {"OPSC_4":"5-37","OPS_Gruppen_Text":"Rhythmuschirurgie und andere Operationen an Herz und Perikard"},
    {"OPSC_4":"5-38","OPS_Gruppen_Text":"Inzision, Exzision und Verschluß von Blutgefäßen "},
    {"OPSC_4":"5-39","OPS_Gruppen_Text":"Andere Operationen an Blutgefäßen "},
    {"OPSC_4":"5-40","OPS_Gruppen_Text":"Operationen am Lymphgewebe "},
    {"OPSC_4":"5-41","OPS_Gruppen_Text":"Operationen an Milz und Knochenmark "},
    {"OPSC_4":"5-42","OPS_Gruppen_Text":"Operationen am Ösophagus "},
    {"OPSC_4":"5-43","OPS_Gruppen_Text":"Inzision, Exzision und Resektion am Magen "},
    {"OPSC_4":"5-44","OPS_Gruppen_Text":"Erweiterte Magenresektion und andere Operationen am Magen "},
    {"OPSC_4":"5-45","OPS_Gruppen_Text":"Inzision, Exzision, Resektion und Anastomose an Dünn- und Dickdarm "},
    {"OPSC_4":"5-46","OPS_Gruppen_Text":"Andere Operationen an Dünn- und Dickdarm "},
    {"OPSC_4":"5-47","OPS_Gruppen_Text":"Operationen an der Appendix "},
    {"OPSC_4":"5-48","OPS_Gruppen_Text":"Operationen am Rektum "},
    {"OPSC_4":"5-49","OPS_Gruppen_Text":"Operationen am Anus "},
    {"OPSC_4":"5-50","OPS_Gruppen_Text":"Operationen an der Leber "},
    {"OPSC_4":"5-51","OPS_Gruppen_Text":"Operationen an Gallenblase und Gallenwegen "},
    {"OPSC_4":"5-52","OPS_Gruppen_Text":"Operationen am Pankreas "},
    {"OPSC_4":"5-53","OPS_Gruppen_Text":"Verschluß abdominaler Hernien "},
    {"OPSC_4":"5-54","OPS_Gruppen_Text":"Andere Operationen in der Bauchregion "},
    {"OPSC_4":"5-55","OPS_Gruppen_Text":"Operationen an der Niere "},
    {"OPSC_4":"5-56","OPS_Gruppen_Text":"Operationen am Ureter "},
    {"OPSC_4":"5-57","OPS_Gruppen_Text":"Operationen an der Harnblase "},
    {"OPSC_4":"5-59","OPS_Gruppen_Text":"Andere Operationen an den Harnorganen "},
    {"OPSC_4":"5-60","OPS_Gruppen_Text":"Operationen an Prostata und Vesiculae seminales "},
    {"OPSC_4":"5-61","OPS_Gruppen_Text":"Operationen an Skrotum und Tunica vaginalis testis"},
    {"OPSC_4":"5-62","OPS_Gruppen_Text":"Operationen am Hoden "},
    {"OPSC_4":"5-65","OPS_Gruppen_Text":"Operationen am Ovar "},
    {"OPSC_4":"5-68","OPS_Gruppen_Text":"Inzision, Exzision und Exstirpation des Uterus "},
    {"OPSC_4":"5-70","OPS_Gruppen_Text":"Operationen an Vagina und Douglasraum "},
    {"OPSC_4":"5-71","OPS_Gruppen_Text":"Operationen an der Vulva "},
    {"OPSC_4":"5-85","OPS_Gruppen_Text":"Operationen an Muskeln, Sehnen, Faszien und Schleimbeuteln"},
    {"OPSC_4":"5-87","OPS_Gruppen_Text":"Exzision und Resektion der Mamma "},
    {"OPSC_4":"5-89","OPS_Gruppen_Text":"Operationen an Haut und Unterhaut "},
    {"OPSC_4":"5-90","OPS_Gruppen_Text":"Operative Wiederherstellung und Rekonstruktion von Haut und Unterhaut"},
    {"OPSC_4":"5-91","OPS_Gruppen_Text":"Andere Operationen an Haut und Unterhaut "},
    {"OPSC_4":"5-93","OPS_Gruppen_Text":"Angaben zum Transplantat und zu verwendeten Materialien"},
    {"OPSC_4":"5-98","OPS_Gruppen_Text":"Spezielle Operationstechniken und Operationen bei speziellen Versorgungssituationen "},
    {"OPSC_4":"8-13","OPS_Gruppen_Text":"Manipulation am Harntrakt"},
    {"OPSC_4":"8-14","OPS_Gruppen_Text":"Therapeutische Kathedirisierung, Aspiration, Punktion und Spülung "},
    {"OPSC_4":"8-15","OPS_Gruppen_Text":"Therapeutische Aspiration und Entleerung durch Punktion "},
    {"OPSC_4":"8-17","OPS_Gruppen_Text":"Spülung (Lavage) "},
    {"OPSC_4":"8-19","OPS_Gruppen_Text":"Verbände "},
    {"OPSC_4":"8-77","OPS_Gruppen_Text":"Maßnahmen im Rahmen der Reanimation "},
    {"OPSC_4":"8-92","OPS_Gruppen_Text":"Neurologisches Monitoring "},
])
EOF
    
    OVERRIDE+=" -f ./$PROJECT/modules/ovis-compose.yml"
fi
