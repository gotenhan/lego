require 'spec_helper'

describe Legit::Values::StringValue do

  it 'parses string' do
    subject.user_value = 'foo'
    subject.parse_and_validate.should be_success_just('foo')
  end

  it 'no stripping by default' do
    subject.user_value = '  bar   '
    subject.parse_and_validate.should be_success_just('  bar   ')
  end

  it 'rejects non-strings' do
    subject.user_value = 23
    subject.parse_and_validate.should be_failure('not a string: 23')
  end

  context 'required => true' do

    it 'nil is missing' do
      subject.user_value = nil
      subject.parse_and_validate.should be_failure('is required')
    end

    it 'empty is missing' do
      subject.user_value = ''
      subject.parse_and_validate.should be_failure('is required')
    end

    it 'blank strings are not empty unless stripped' do
      subject.user_value = ' '
      subject.parse_and_validate.should be_success_just(' ')
    end

    it 'blank strings are empty if stripped' do
      s = Legit::Values::StringValue.new(strip: true)
      s.user_value = ' '
      s.parse_and_validate.should be_failure('is required')
    end

  end

  context 'required => false' do

    subject { Legit::Values::StringValue.new({required: false}) }

    it 'drops nil' do
      subject.user_value = nil
      subject.parse_and_validate.should be_success_nothing
    end

    it 'drops empty strings' do
      subject.user_value = ''
      subject.parse_and_validate.should be_success_nothing
    end

    it 'parses blank strings' do
      subject.user_value = '  '
      subject.parse_and_validate.should be_success_just('  ')
    end

    it 'drops blank strings if stripped' do
      s = Legit::Values::StringValue.new(strip: true, required: false)
      s.user_value = '  '
      s.parse_and_validate.should be_success_nothing
    end

  end

  it 'downcases' do
    s = Legit::Values::StringValue.new(downcase: true)
    s.user_value = 'foo$B4RbaZ'
    s.parse_and_validate.should be_success_just('foo$b4rbaz')
  end

  it 'upcases' do
    s = Legit::Values::StringValue.new(upcase: true)
    s.user_value = 'foo$B4RbaZ'
    s.parse_and_validate.should be_success_just('FOO$B4RBAZ')
  end

end
