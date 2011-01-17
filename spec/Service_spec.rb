require './spec_helper'

describe Salut::Service do
  before do
    Salut.log.level = Logger::WARN
  end

  describe '#advertising?' do
    before do
      @service = Salut::Service.new({
        port:3000,
        instance_name:'Test',
        service_type:'_http._tcp.'
      })
    end

    it 'should be initialized to false' do
      @service.advertising?.should.be.equal false
    end

    it 'should be false when I start advertising (until #netServiceDidPublish is called)' do
      @service.start_advertising
      @service.advertising?.should.be.equal false
    end

    it 'should be false after I stop advertising' do
      @service.start_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 2
      @service.stop_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 2
      @service.advertising?.should.be.equal false
    end

    it 'should be false if advertising fails' do
      @other_service = @service.dup
      @service.start_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 2
      @other_service.start_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 2
      @other_service.advertising?.should.be.equal false
    end

    it 'should be true when advertising is successful' do
      @service.start_advertising
      NSRunLoop.currentRunLoop.runUntilDate Time.now + 2
      @service.advertising?.should.be.equal true
    end
  end


end
