import unittest


def test_base():
    assert True


class MyTest(unittest.TestCase):
    def test_method1(self):
        assert True

    def test_method2(self):
        assert True
