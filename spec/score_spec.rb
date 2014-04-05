# -*- coding: utf-8 -*-
require 'spec_helper'

describe PocketMiku::Score, "pocket miku score" do
  before do
    @score = PocketMiku::Score.new
  end

  it "should get/set default data" do
    expect { @score.default.key = -1 }.to raise_error(PocketMiku::ArgumentError)
    expect { @score.default.key = 128 }.to raise_error(PocketMiku::ArgumentError)
    expect { @score.default.velocity = -1 }.to raise_error(PocketMiku::ArgumentError)
    expect { @score.default.velocity = 128 }.to raise_error(PocketMiku::ArgumentError)
    expect { @score.default.pitchbend = -8193 }.to raise_error(PocketMiku::ArgumentError)
    expect { @score.default.pitchbend = 8192 }.to raise_error(PocketMiku::ArgumentError)
    expect { @score.default.length = 0 }.to raise_error(PocketMiku::ArgumentError)

    @score.default.key = 0
    expect(@score.default.key).to eq 0
    @score.default.key = 127
    expect(@score.default.key).to eq 127
    @score.default.velocity = 0
    expect(@score.default.velocity).to eq 0
    @score.default.velocity = 127
    expect(@score.default.velocity).to eq 127
    @score.default.pitchbend = -8192
    expect(@score.default.pitchbend).to eq(-8192)
    @score.default.pitchbend = 8191
    expect(@score.default.pitchbend).to eq 8191
    @score.default.length = 1
    expect(@score.default.length).to eq 1
  end

  it "should can recording" do
    @score.record do
      あ 60
    end
  end

end
