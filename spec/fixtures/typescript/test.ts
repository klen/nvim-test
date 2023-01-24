var assert = require('assert');

describe("tstest", (): void => {
  describe(`ns`, (): void => {
    it("test1", (): void => {
      // assertions
    });
  });
});

describe('mocha', function () {
  describe(`ns`, function () {
    it('test2', function () {
      // assertions
      assert.ok(true);
    });
    it('test3', function () {
      // assertions
      assert.ok(true);
    });
  });
});
