-- Migration: Create documents table for persistent storage of course documents
-- Run this in Supabase SQL Editor to create the table structure

CREATE TABLE IF NOT EXISTS documents (
  id bigserial primary key,
  course_title text not null,
  file_name text not null,
  file_url text not null,
  uploaded_by text not null,
  uploaded_at timestamp default now(),
  created_at timestamp default now()
);

-- Create index on course_title for faster queries
CREATE INDEX IF NOT EXISTS idx_documents_course_title ON documents(course_title);

-- Enable Row Level Security
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Create RLS policy to allow authenticated users to insert their own documents
CREATE POLICY "Allow authenticated users to insert documents" ON documents
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated_user');

-- Create RLS policy to allow authenticated users to read all documents
CREATE POLICY "Allow authenticated users to read documents" ON documents
  FOR SELECT
  USING (auth.role() = 'authenticated_user');

-- Create RLS policy to allow users to delete their own documents
CREATE POLICY "Allow users to delete their own documents" ON documents
  FOR DELETE
  USING (uploaded_by = auth.uid()::text);
