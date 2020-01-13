Feature: TestCase @throws
  In order to have TestCases have relaxed @throws requirements
  As a Psalm user
  I need Psalm to typecheck my testcases

  Background:
    Given I have the following config
      """
      <?xml version="1.0"?>
      <psalm checkForThrowsDocblock="true">
        <projectFiles>
          <directory name="."/>
          <ignoreFiles> <directory name="../../vendor"/> </ignoreFiles>
        </projectFiles>
        <plugins>
          <pluginClass class="Psalm\PhpUnitPlugin\Plugin"/>
        </plugins>
      </psalm>
      """
    And I have the following code preamble
      """
      <?php
      namespace NS;
      use PHPUnit\Framework\TestCase;

      """

  Scenario: uncaught exception triggers error
    Given I have the following code
      """
      class MyTestCase extends TestCase
      {
        /** @return void */
        public function testSomething() {
          throw new \InvalidArgumentException('foo');
        }
      }
      """
    When I run Psalm
    Then I see these errors
      | Type            | Message                                                                                                     |
      | MissingThrowsDocblock | InvalidArgumentException is thrown but not caught - please either catch or add a @throws annotation |
    And I see no other errors

  Scenario: expected exception triggers no errors
    Given I have the following code
      """
      class MyTestCase extends TestCase
      {
        /** @return void */
        public function testSomething() {
          $this->expectException(\InvalidArgumentException::class);
          throw new \InvalidArgumentException('foo');
        }
      }
      """
    When I run Psalm
    Then I see no errors

  Scenario: expected exception called statically triggers no errors
    Given I have the following code
      """
      class MyTestCase extends TestCase
      {
        /** @return void */
        public function testSomething() {
          static::expectException(\InvalidArgumentException::class);
          throw new \InvalidArgumentException('foo');
        }
      }
      """
    When I run Psalm
    Then I see no errors
