
const { Client } = require('pg');

const client = new Client({
  host: 'host.docker.internal',
  port: 5432,
  user: 'pioneer',
  password: 'pioneer123',
  database: 'pioneer'
});

async function createFlags() {
  try {
    await client.connect();
    
    const flags = [
      { title: 'dashboard_enabled', description: 'Enable main dashboard access', is_active: true },
      { title: 'login_enabled', description: 'Enable login functionality', is_active: true },
      { title: 'registration_enabled', description: 'Enable user registration', is_active: true },
      { title: 'otp_verification_enabled', description: 'Enable OTP verification', is_active: true }
    ];
    
    for (const flag of flags) {
      await client.query(
        'INSERT INTO flags (title, description, is_active, version, rollout, updated_at, created_at) VALUES (cd /Users/manish/Documents/GitHub/zero/agentmitra && echo "
const { Client } = require('pg');

const client = new Client({
  host: 'host.docker.internal',
  port: 5432,
  user: 'pioneer',
  password: 'pioneer123',
  database: 'pioneer'
});

async function createFlags() {
  try {
    await client.connect();
    
    const flags = [
      { title: 'dashboard_enabled', description: 'Enable main dashboard access', is_active: true },
      { title: 'login_enabled', description: 'Enable login functionality', is_active: true },
      { title: 'registration_enabled', description: 'Enable user registration', is_active: true },
      { title: 'otp_verification_enabled', description: 'Enable OTP verification', is_active: true }
    ];
    
    for (const flag of flags) {
      await client.query(
        'INSERT INTO flags (title, description, is_active, version, rollout, updated_at, created_at) VALUES ($1, $2, $3, 1, 100, NOW(), NOW()) ON CONFLICT (title) DO NOTHING',
        [flag.title, flag.description, flag.is_active]
      );
      console.log(\`Created flag: \${flag.title}\`);
    }
    
    console.log('All flags created successfully');
  } catch (error) {
    console.error('Error creating flags:', error);
  } finally {
    await client.end();
  }
}

createFlags();
" > create_flags.js, , , 1, 100, NOW(), NOW()) ON CONFLICT (title) DO NOTHING',
        [flag.title, flag.description, flag.is_active]
      );
      console.log(`Created flag: ${flag.title}`);
    }
    
    console.log('All flags created successfully');
  } catch (error) {
    console.error('Error creating flags:', error);
  } finally {
    await client.end();
  }
}

createFlags();

