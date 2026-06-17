const rootUsername = process.env.OVIS_ROOT_USERNAME || 'ovis-root';
const databaseName = process.env.DB || 'onc_test';

db = db.getSiblingDB(databaseName);
db.createCollection('user');
db.user.insertMany([
	{
		_id: rootUsername,
		createdAt: new Date(),
		createdBy: 'system',
		role: 'super-admin',
		status: 'active',
		pseudonymization: false,
		darkMode: false,
		colorTheme: 'CCCMunich',
		language: 'en'
	}
]);
