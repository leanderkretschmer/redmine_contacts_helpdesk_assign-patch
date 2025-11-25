# This file is a part of Redmine Helpdesk (redmine_helpdesk) plugin,
# customer support management plugin for Redmine
#
# Copyright (C) 2011-2025 RedmineUP
# http://www.redmineup.com/
#
# redmine_helpdesk is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_helpdesk is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_helpdesk.  If not, see <http://www.gnu.org/licenses/>.

Redmine::Plugin.register :redmine_contacts_helpdesk do
  name "Redmine Helpdesk plugin (PRO version) + Assign Patch"
  author 'RedmineUP'
  description 'This is a Helpdesk plugin for Redmine'
  version '4.2.5.1'
  url 'https://www.redmineup.com/pages/plugins/helpdesk'
  author_url 'mailto:support@redmineup.com'

  requires_redmine version_or_higher: '4.0'

  begin
    requires_redmine_plugin :redmine_contacts, version_or_higher: '4.3.9'
  rescue Redmine::PluginNotFound  => e
    raise "Please install redmine_contacts plugin"
  end

  settings default: {
    "helpdesk_answer_from" => '',
    "helpdesk_add_contact_notes" => '1',
    "helpdesk_answer_subject" => 'Re: {%ticket.subject%} [{%ticket.tracker%} #{%ticket.id%}]',
    "helpdesk_first_answer_subject" => '{%ticket.project%} support message [{%ticket.tracker%} #{%ticket.id%}]',
    "helpdesk_first_answer_template" => "Hello, {%contact.first_name%}\n\nWe hereby confirm that we have received your message.\n\nWe will handle your request and get back to you as soon as possible.\n\nYour request has been assigned the following case ID #\{%ticket.id%}.",
    "helpdesk_assign_contact_user" => 0,
    "helpdesk_create_private_tickets" => 0,
    "helpdesk_autoclose_tickets_time_unit" => 'day'
  }, partial: 'settings/helpdesk'

  project_module :contacts_helpdesk do
     permission :view_helpdesk_tickets, helpdesk: [:show_original],
                                        canned_responses: [:add],
                                        helpdesk_tickets: [:index, :show]
     permission :view_helpdesk_reports, helpdesk_reports: [:show, :render_chart]
     permission :send_response, issues: [:send_helpdesk_response, :email_note],
                                helpdesk: [:show_original, :create_ticket, :delete_spam],
                                journal_messages: [:create]
     permission :edit_helpdesk_settings, helpdesk: [:save_settings, :get_mail],
                                         helpdesk_oauth: [:auth, :auth_remove]
     permission :edit_helpdesk_tickets, helpdesk_tickets: [:create, :update, :edit, :destroy, :bulk_update_reply],
                                        journal_messages: [:create],
                                        helpdesk_duplicate_tickets: [:index, :merge, :search]
     # Canned responses
     permission :manage_public_canned_responses, {canned_responses: [:new, :create, :edit, :update, :destroy]}, require: :member
     permission :manage_canned_responses, {canned_responses: [:new, :create, :edit, :update, :destroy]}, require: :loggedin
  end

  menu :admin_menu, :helpdesk, {controller: 'settings', action: 'plugin', id: "redmine_contacts_helpdesk"},
                                caption: :label_helpdesk,
                                param: :project_id,
                                html: {class: 'icon'},
                                icon: 'support',
                                plugin: :redmine_contacts_helpdesk

  activity_provider :helpdesk_tickets, default: false, class_name: ['HelpdeskTicket', 'JournalMessage']

end

if (Rails.configuration.respond_to?(:autoloader) && Rails.configuration.autoloader == :zeitwerk) || Rails.version > '7.0'
  Rails.autoloaders.each { |loader| loader.ignore(File.dirname(__FILE__) + '/lib') }
end

Rails.configuration.after_initialize do
  require File.dirname(__FILE__) + '/lib/redmine_helpdesk'
end
