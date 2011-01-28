require File.dirname(__FILE__) + '/spec_helper.rb'

describe Mapel do
  before do
    @input      = File.dirname(__FILE__) + '/fixtures'
    @output     = File.dirname(__FILE__) + '/output'
    @logo       = @input + '/ImageMagick.jpg'
    @multi_word = @input + '/multi-word file.jpg'
  end

  after do
    Dir.glob(@output + '/*') { |f| File.delete(f) }
  end

  it "should respond to #info" do
    Mapel.respond_to?(:info).should == true
  end

  it "should respond to #render" do
    Mapel.respond_to?(:render).should == true
  end

  it "should support compact rendering syntax" do
    Mapel(@logo).should.be.kind_of(Mapel::Engine)
  end

  describe "#info" do
    it "should return basic image metadata" do
      Mapel.info(@logo)[:path].should == @logo
      Mapel.info(@logo)[:format].should == 'JPEG'
      Mapel.info(@logo)[:dimensions].should == [572, 591]
      Mapel.info(@logo)[:depth].should == '8-bit'
      Mapel.info(@logo)[:size].should == '97.4KB'
    end

    it "should be able to read files with spaces in the filename" do
      Mapel.info(@multi_word)[:path].should == @multi_word
    end
  end

  describe "#render" do
    it "should be able to scale an image" do
      cmd = Mapel(@logo).scale('50%').to(@output + '/scaled.jpg').run
      cmd.status.should == true
      Mapel.info(@output + '/scaled.jpg')[:dimensions].should == [286, 296]
    end

    it "should be able to crop an image" do
      cmd = Mapel(@logo).crop('50x50+0+0').to(@output + '/cropped.jpg').run
      cmd.status.should == true
      Mapel.info(@output + '/cropped.jpg')[:dimensions].should == [50, 50]
    end

    it "should be able to resize an image" do
      cmd = Mapel(@logo).resize('100x').to(@output + '/resized.jpg').run
      cmd.status.should == true
      Mapel.info(@output + '/resized.jpg')[:dimensions].should == [100, 103]
    end

    it "should be able to crop-resize an image" do
      cmd = Mapel(@logo).gravity(:west).resize!('50x100').to(@output + '/crop_resized.jpg').run
      cmd.status.should == true
      Mapel.info(@output + '/crop_resized.jpg')[:dimensions].should == [50, 100]
    end

    it "should allow arbitrary addition of commands to the queue" do
      cmd = Mapel(@logo).gravity(:west)
      cmd.resize(50, 50)
      cmd.to_preview.should == "convert \"#{@logo}\" -gravity west -resize \"50x50\""
    end

    it "should be able to handle input filenames containing spaces" do
      cmd = Mapel(@multi_word).resize('100x').to(@output + '/resized.jpg').run
      cmd.status.should == true
      Mapel.info(@output + '/resized.jpg')[:dimensions].should == [100, 103]
    end

    it "should be able to handle output filenames containing spaces" do
      output = @output + '/multi-word file.jpg'
      cmd    = Mapel(@logo).resize('100x').to(output).run
      cmd.status.should == true
      Mapel.info(output)[:dimensions].should == [100, 103]
    end
  end
end
