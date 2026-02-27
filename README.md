Student Record Management System is a desktop-based CRUD application built using Python and Tkinter. It allows users to manage student records including adding, searching, updating, viewing, and deleting student information stored in a MySQL database.

The system focuses on simplicity, clarity, and predictable behavior.
Tech Stack

Language: Python 3

GUI: Tkinter

Database: MySQL

Database Driver: PyMySQL

Features

Add new student records

Search student by roll number, name, or subject

Update student details

Delete student records

View all records

Tabular data display using TreeView

Database Schema

Database: rec

Table: student

Column	Type	Description
rollNo	INT	Primary Identifier
name	VARCHAR	Student Name
fname	VARCHAR	Father Name
sub	VARCHAR	Subject
grade	VARCHAR	Grade

Example SQL:

CREATE DATABASE rec;

USE rec;

CREATE TABLE student (
    rollNo INT PRIMARY KEY,
    name VARCHAR(100),
    fname VARCHAR(100),
    sub VARCHAR(100),
    grade VARCHAR(10)
);
Architecture Overview

The application is structured around a single controller class:

std
 ├── UI Initialization
 ├── Database Connection Layer
 ├── CRUD Operations
 └── Table Rendering Logic

Responsibilities:

UI Layer: Handles Tkinter components and layout

Data Layer: Handles MySQL operations

Interaction Layer: Connects UI events to database operations

Key Technical Decisions
1. Tkinter for GUI

Chosen for:

Built-in Python support

Lightweight desktop interface

No external frontend framework required

2. TreeView for Data Display

Provides:

Structured tabular view

Scrollable interface

Dynamic row updates

3. Parameterized Queries

Used %s placeholders for preventing SQL injection in values.

4. Separate Frame Strategy

Each operation (Add, Search, Update, Delete) uses a dynamic frame that replaces previous input forms.

How to Run

Install MySQL

Create database and table using schema above

Install dependencies:

pip install pymysql

Run:

python app.py



First Website is a responsive web interface designed in Figma.
The goal of this project was to create a clean, structured, and scalable website layout with clear component boundaries and reusable design patterns.

The design focuses on:

Clarity

Visual hierarchy

Component consistency

Responsive behavior

Simplicity over visual complexity

Tools Used

Figma

Auto Layout

Components & Variants

Grid system

Reusable typography styles

Design tokens (colors, spacing)

Design Goals

Clear Information Hierarchy

Component Reusability

Scalable Layout Structure

Mobile-Responsive Layout

Simple and Predictable UI

Page Structure
1. Landing Page

Navigation Bar

Hero Section

Features Section

Call-To-Action Section

Footer

Component System

The design uses reusable components:

Navbar

Buttons (Primary / Secondary variants)

Cards

Section Containers

Footer

All components follow consistent:

Spacing rules

Typography scale

Color palette

Border radius system

Design System
Color Palette

Primary: Brand color used for CTAs
Secondary: Neutral background color
Accent: Highlight elements

Typography

Heading 1 – Hero Titles

Heading 2 – Section Titles

Body – Paragraph text

Small – Secondary labels

Typography scale ensures consistent hierarchy.

Layout Strategy

12-column grid system

Consistent horizontal padding

Section-based spacing

Auto-layout for responsiveness

Responsiveness

The design supports:

Desktop layout

Tablet layout

Mobile layout

Components adapt using:

Auto layout constraints

Flexible width containers

Vertical stacking on small screens

Key Design Decisions
1. Component-Based Design

All repeating UI elements are converted into reusable components.
This improves maintainability and consistency.

2. Minimal Visual Noise

Focus was placed on:

White space

Clear CTA buttons

Reduced visual clutter

3. Clear Call-To-Action

Primary buttons use strong contrast color to guide user interaction.

Accessibility Considerations

High contrast color usage

Clear readable font sizes

Logical layout flow

Future Improvements

Dark mode variant

Design token export for developers

Interactive prototype flows

Animation guidelines

Accessibility audit pass
