require 'rails_helper'
require 'benchmark'


RSpec.describe Record, type: :model do
  p "#{Record.count} records in DB"
  multiplier = 300000000/Record.count
  #1.1
  it 'makes search for Client IP less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(client_ip: '::ffff:192.168.10.37')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #2
  it 'Domain search less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(domain: 'vk.com')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #3
  it 'makes search for Destination IP less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(destination_ip: '::ffff:5.9.115.76')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #4
  it 'Client IP + URI less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(domain: 'vk.com', client_ip: '::ffff:192.168.10.37')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #5
  it 'Client IP + Dest IP less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(destination_ip: '::ffff:185.21.188.13', client_ip: '::ffff:192.168.10.99')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #6
  it 'Client IP + port less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(client_ip: '::ffff:192.168.10.99', client_port: '55147')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #7
  it 'Domain + Dest port less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(domain: 'mikero', destination_port: '80')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #8
  it 'Dest IP+ Dest port less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(destination_ip: '::ffff:192.168.10.1', destination_port: '8080')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #9
  it 'Client IP + Client port + domain less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(client_ip: '::ffff:192.168.10.72', client_port: '53062', domain: 'drive2.ru')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #10
  it 'Client IP + Client port + Dest IP less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(client_ip: '::ffff:192.168.10.75', client_port: '61357', destination_ip: '::ffff:185.79.118.28')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #11
  it 'Client IP + Client port + domain + destination port less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(client_ip: '::ffff:192.168.10.72', client_port: '53062', domain: 'drive2.ru', destination_port: '8080')
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end

  #12
  it 'Client IP + Client port + IP dest + destination port less than 30s' do
    res = []
    time_to_transform = Benchmark.realtime do
      res = Record.search(client_ip: '::ffff:192.168.10.103', client_port: '58125', destination_ip: '::ffff:91.235.143.104', destination_port: 80)
    end
    p "#{time_to_transform * multiplier} of 30"
    expect res.size > 0
    expect(time_to_transform * multiplier).to be <= 30.0
  end




end