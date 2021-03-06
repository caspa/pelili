# Redmine - project management software
# Copyright (C) 2006-2008  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.dirname(__FILE__) + '/../test_helper'

class NewsTest < Test::Unit::TestCase
  fixtures :projects, :users, :roles, :members, :enabled_modules, :news

  def setup
  end
  
  def test_should_include_news_for_projects_with_news_enabled
    project = projects(:projects_001)
    assert project.enabled_modules.any?{ |em| em.name == 'news' }

    # News.latest should return news from projects_001
    assert News.latest.any? { |news| news.project == project }
  end
  
  def test_should_not_include_news_for_projects_with_news_disabled
    # The projects_002 (OnlineStore) doesn't have the news module enabled, use that project for this test
    project = projects(:projects_002)
    assert ! project.enabled_modules.any?{ |em| em.name == 'news' }

    # Add a piece of news to the project
    news = project.news.create(:title => 'Test news', :description => 'This should not be returned by News.latest')

    # News.latest should not return that new piece of news
    assert News.latest.include?(news) == false
  end
  
  def test_should_only_include_news_from_projects_visibly_to_the_user
    # users_001 has no memberships so can only get news from public project
    assert News.latest(users(:users_001)).all? { |news| news.project.is_public? } 
  end
  
  def test_should_limit_the_amount_of_returned_news
    # Make sure we have a bunch of news stories
    10.times { projects(:projects_001).news.create(:title => 'Test news', :description => 'Lorem ipsum etc') }
    assert_equal 2, News.latest(users(:users_002), 2).size
    assert_equal 6, News.latest(users(:users_002), 6).size
  end

  def test_should_return_5_news_stories_by_default
    # Make sure we have a bunch of news stories
    10.times { projects(:projects_001).news.create(:title => 'Test news', :description => 'Lorem ipsum etc') }
    assert_equal 5, News.latest(users(:users_004)).size
  end
end
