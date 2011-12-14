# == Schema Information
#
# Table name: entries
#
#  id             :integer         not null, primary key
#  time_frame_id  :integer         not null
#  kind           :string(255)     not null
#  title          :string(255)     not null
#  description    :text
#  value          :float           default(0.0), not null
#  bill_on        :date
#  auto_debit     :boolean         default(FALSE), not null
#  credit_card_id :integer
#  done           :boolean         default(FALSE), not null
#  deleted_at     :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

require 'spec_helper'

describe Entry do
  it 'has a valid factory' do
    FactoryGirl.build(:entry).should be_valid
  end

  it { should validate_presence_of :time_frame_id }
  it { should validate_presence_of :kind }
  it { should validate_presence_of :title }
  it { should validate_presence_of :value }

  it { should_not allow_value(nil).for(:auto_debit) }
  [true, false].each { |auto_debit| it { should allow_value(auto_debit).for(:auto_debit) }}

  it { should_not allow_value(nil).for(:done) }
  [true, false].each { |done| it { should allow_value(done).for(:done) }}

  [nil, 'other'].each { |kind| it { should_not allow_value(kind).for(:kind) }}
  EntryKind.list.each { |kind| it { should allow_value(kind).for(:kind) }}

  it { should belong_to :time_frame }
  # it { should belong_to :credit_card }

  describe '#status' do
    it 'returns done' do
      entry = FactoryGirl.create(:entry, :bill_on => 1.day.ago.to_date, :done => true)
      entry.status.should == EntryStatus::DONE
    end

    it 'returns done if it have no bill_on' do
      entry = FactoryGirl.create(:entry, :bill_on => nil, :done => true)
      entry.status.should == EntryStatus::DONE
    end

    it 'returns warning' do
      entry = FactoryGirl.create(:entry, :bill_on => 5.day.from_now.to_date, :done => false)
      entry.status.should == EntryStatus::WARNING
    end

    it 'returns late' do
      entry = FactoryGirl.create(:entry, :bill_on => 1.day.ago.to_date, :done => false)
      entry.status.should == EntryStatus::LATE
    end

    it 'returns pending' do
      entry = FactoryGirl.create(:entry, :bill_on => 8.day.from_now.to_date, :done => false)
      entry.status.should == EntryStatus::PENDING
    end

    it 'returns pending if it have no bill_on' do
      entry = FactoryGirl.create(:entry, :bill_on => nil, :done => false)
      entry.status.should == EntryStatus::PENDING
    end
  end
end
