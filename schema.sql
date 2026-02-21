CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE tenant (
  tenant_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  status TEXT,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE app_user (
  user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID REFERENCES tenant(tenant_id),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT,
  status TEXT,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE patient (
  patient_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID REFERENCES tenant(tenant_id),
  mrn TEXT,
  first_name TEXT,
  last_name TEXT,
  dob DATE,
  sex TEXT,
  status TEXT,
  created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE audit_log (
  audit_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID,
  user_id UUID,
  action TEXT,
  resource_type TEXT,
  resource_id UUID,
  occurred_at TIMESTAMP DEFAULT now()
);