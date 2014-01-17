require 'spec_helper'

describe CodeTranslate do
  describe ".translate" do
    let(:code) { double }

    it "should translate ruby" do
      CodeTranslate::Ruby.should_receive(:translate).with(code)
      CodeTranslate.translate(:ruby, code)
    end

    it "should do nothing with php" do
      CodeTranslate.translate(:php, code).should == code
    end

    it "should do nothing with python" do
      CodeTranslate.translate(:python, code).should == code
    end
  end

  describe "Ruby" do
    describe ".translate" do
      it "should do a series of translations and return the final result" do
        input, output1, output2, output3 = double, double, double, double
        CodeTranslate::Ruby.should_receive(:add_require).with(input).and_return(output1)
        CodeTranslate::Ruby.should_receive(:change_table_in_sqliteexecute_and_select).with(output1).and_return(output2)
        CodeTranslate::Ruby.should_receive(:switch_to_scraperwiki_morph).with(output2).and_return(output3)
        CodeTranslate::Ruby.translate(input).should == output3
      end
    end

    describe ".add_require" do
      it "should replace scraperwiki with scraperwiki-morph (with single quotes)" do
        CodeTranslate::Ruby.add_require("require 'scraperwiki'\nsome other code\n").should ==
          "require 'scraperwiki-morph'\nsome other code\n"
      end

      it "should replace scraperwiki with scraperwiki-morph (with double quotes)" do
        CodeTranslate::Ruby.add_require("require \"scraperwiki\"\nsome other code\n").should ==
          "require 'scraperwiki-morph'\nsome other code\n"
      end

      it "should add the require if it's not there" do
        CodeTranslate::Ruby.add_require("some code\n").should ==
          "require 'scraperwiki-morph'\nsome code\n"
      end

      describe ".switch_to_scraperwiki_morph" do
        it "should replace all uses of ScraperWiki with ScraperWikiMorph" do
          CodeTranslate::Ruby.switch_to_scraperwiki_morph("if foo\n  ScraperWiki.select(twiddle, bob)\nend\n").should ==
            "if foo\n  ScraperWikiMorph.select(twiddle, bob)\nend\n"
        end
      end

      describe ".change_table_in_sqliteexecute_and_select" do
        it "should replace the table name" do
          CodeTranslate::Ruby.change_table_in_sqliteexecute_and_select( \
            "ScraperWiki.save_sqlite(swdata)\nScraperWiki.sqliteexecute('select * from swdata', foo, bar)\nScraperWiki.select('select * from swdata; select * from swdata', foo, bar)\n").should ==
            "ScraperWiki.save_sqlite(swdata)\nScraperWiki.sqliteexecute('select * from data', foo, bar)\nScraperWiki.select('select * from data; select * from data', foo, bar)\n"
        end

        it "another example" do
          CodeTranslate::Ruby.change_table_in_sqliteexecute_and_select( \
            "if (ScraperWiki.select(\"* from swdata where `council_reference`='\#{record['council_reference']}'\").empty? rescue true)").should ==
            "if (ScraperWiki.select(\"* from data where `council_reference`='\#{record['council_reference']}'\").empty? rescue true)"
        end
      end
    end
  end
end
