class CreateRequests < ActiveRecord::Migration 
    def create_request
        create_table :requests do |t|
            t.int :user_tarjimly_id
            t.string :from_language
            t.string :to_language 
            t.string :document 
            t.string :document_type 
            t.datetime :deadline 
            t.string :title 
            t.string :description
            t.string :categories, array: true, default: []
            t.int :num_claims 
            t.string :form_name 
            t.int :_status
            t.timestamps
        end 
    end
