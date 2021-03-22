# SwiftyBandika

A CMS server app for the Mac, based on Swift, NIO and JSON Persistance

This app has been completely written by the author, but beside the Apple libs he used the external libraries of SwiftSoup for prettyfying HTML, Zip for backups, a modified version of CKEditor 4.10 as WYSIWYG web editor and an adapted version of Bootstrap 4 for web styles.

The app can be used for testing, production and pre-production.
If you prefer running the production server on Linux, you will soon be able to use a backup of this app as input for its Java and Tomcat based sister application BandikaJson (also on GitHub).

It features 
- template based content (three levels of templates),
- custom tags for dynamic content
- WYSIWYG editing, 
- draft and published content versions
- right based read, write and publishing access
- JSON based persistence, 
- backup and restore of all created data
- an app based control interface including log viewer, style and template editing
- and much more


It lacks

- more ideas and requests for better satisfying your demands.
- more enthusiastic developers who would like to share this path. 

Just contact me!

# App View

The frontend of the app has two panels: the server and the layout panel.

## Server Panel

On the server panel you can set the basic configuration and start and stop the HTTP server.

### Configuration

Here you can set 
- the App name (for the web as well),
- the web host name (which should be known to the system) and 
- the web port (which should not be occupied by another app).

### Backups

You can also create and restore backups. So if you make changes, you should create a backup first.
Backups include all data, settings, designs and templates.
Make sure the server ist stopped, before you restore a backup.

### Log View

The right side of this panel shows the log with all important runtime information.
Warnings and errors are highlighted.

## Layout Panel

### Logo and Styles

On the layout panel you can edit your design including the logo, style sheet and style images.

### Templates

You can also create and update your templates using HTML and special <spg:...> tags.
You will always need a default master template, so you cannot delete it.
Templates are always embedded in an xml tag which holds the template's attributes.

The starting point for the layout and its templates is the current blue one, which is also used for administration pages.

## Usage

All other instructions how to use this CMS you will find on the default home page after you started the server.

The login for the super admin is 'root' with the password 'pass'. For production, you should obviously change this.


# Web View

The web view shows content or page is governed by the current content's page type and its master page.

### System Menu

The system menu is a list of small icons on the top right.

##### Home icon (House)

This icon links to the home page (as the logo does).

#### Anonymous Mode Icons

The icons appear when the user is not logged in.

##### Login (Person)

Leads to the login dialog.

#### User Mode Icons

These icons appear when the user is logged in, but depending on the users rights and the current page edit mode.

##### Administration (Gear)

Links to the Adminstration.
This icon appears only if the user has any administration rights.

###### Edit (Pencil)

Opens the current page in edit mode.
This icon appears only if the user has edit rights for this page.

##### View (Eye or slashed eye)

Toggles between the draft and the published view.
This icon appears only if the user has edit rights for this page and the page has been changed.

##### Publish (Thumb up)

Publishes the current draft of the page.
This icon appears only if the user has approve rights for this page.

##### Profile (Filled Person)
Link to the current usres profile page, where he/she can edit certain attributes and change the password. The password minimum length is 8 characters.
##### Logout icon (Arrow out)
Logs the current user out, changes to anonymous view.

### Main Menu


##### Logo

The logo is an image, which can be changed in the app. It links to the home page.

##### Top menu items

The top menu items are links to direct child pages of the home page (which have been selected for the main menu).
If a top item has child content, it opens a dropdown with a link to itself and its child contents.

##### Subitems

These are links to the contents.

##### Mobile view

Depending on the browser width, the main menu changes to a mobile view with a 'burger icon'.

### Breadcrumb

This shows the path from the Home page to the current content. Path elements are links to the respective content.

### Content area

The content area shows what is the "content" part of the master page.
It can be viewed in normal or edit mode (if the user has these rights).

#### Default View

The defaut view shows the content as it has been created and edited. If the content has been changed compared to the published version and the user has edit rights, he7she is shown the draft version. This can be changed by the 'eye' icon in the system menu.

#### Edit View

The edit view allows direct editing of all editable parts of the page. 

##### Save and Cancel

At the top of this view there are Save and Cancel buttons to save or cancel the current changes.

**Important:** If changes are not saved and the page is closed, all changes are lost!

#### Page Types

Depending on the page types and templates, the edit areas may differ. So a full page layout has just one dit area, whereas a template based page may have several sections which can be filled by parts and their editable fields.

#### Templates

Beside the master templates, which govern the area around the content, there are page templates for the content layout and part templates for single parts in sections of the content.

#### Sections

Sections are areas for parts (maybe with own templates), which are defined in a page template.
Typical sections are columns for main and aside content.

#### Parts

Part are small items which can be added to a section. Parts can be program defined like a list of subcontent or a list of usres, or it can be template based with editable fields like text field, html field or image field.

### Footer

##### Footer Links

Footer links point to content, which in the administration has been set a footer content. Typically these are imprints or legal pages.


##Web Administration

The web administration is split into user/group administration and contentadministration.

### User Administration

#### Groups

Groups are groups of users, mostly for assigning rights.

##### Add Group (Plus sign)

A dialog lets you set name, global rights and members.

##### Edit Group (Pencil)

A dialog lets you change name, global rights and members.

##### Delete Group (Trash)

Deletes the group permanently.

#### Users

Users have the usual attributes and may be member of one or more groups.

##### Add User (Plus sign)

A dialog lets you set the attributes and group memberships.
Last name, login name, password and email are mandatory.

##### Edit User (Pencil)

A dialog lets you change the attributes and group memberships.
Last name, login name, email are mandatory.  If no new password is entered, the old one remains in place.

##### Delete User (Trash)

Deletes the user permanently.
You cannot delete the Superadmin user (root).

### Content Administration

The content administration lets you create content, or edit content settings and their tree structure.
Visual content is edited in wysiwyg mode, that is on the actual page itself.

##### Add (new) Content (Plus with Down Arrow)

A dropdown lets you choose the content type before editing its settings (see below).

##### Paste Content (Filled double Page)

Lets you paste content from the internal clipboard if present.

##### View Content (Eye)

Jumps to the default view of the content.

##### Edit Content Settings (Pencil)

A dialog lets you edit the content's settings, including name, description, anonymous viewing, master template, page template (if any), appearance in menus, active state.

##### Edit Content Rights (Keys)

A dialog lets you set specific right for any group.

##### Sort Child Contents (Up down Arrows)

A dialog lets you change the sequential appearance of child contents in any list (e.g. the menu).

##### Cut Content (Scissor)

Cut cotent to the internal clipboard. Only after pasting the content is actually moved.

##### Copy Content (Empty double Page)

Copy content to the clipboard. During this operation the new content gets a new ID, but all other attributes are exactly copied.

##### Delete Content (Trash)

Deletes the content permanantly.
The root content (Home page) cannot be deleted - it can only be changed.


