# OpenFL Hachethon

```python
python -m pip install --upgrade pip
pip install pytest coverage
pip install -r requirements-test.txt
pip install .
coverage run -m pytest -rA
coverage report
coverage html -d <path_to_dir>
```

# Install

```bash
pip install pytest
```

# Run

```bash
pytest <path_to_dir>
# 扫描<path_to_dir>目录中所有的以test_开头或_test结尾的文件，对这些文件进行单元测试；
# 如果<path_to_dir>为空，则默认扫描当前文件夹
```


# Fixtures

附加`fixtures`标签的函数会生成对象，pytest会记录该对象，并将其作为参数调用其他测试用例。
`fixtures`生成了测试用例的上下文。

### `Fixtures`有下列特征：
1. 可以传递调用
   (一个的fixtures作为下一个fixtures的参数)
2. 可重用
   同一个fixtures被多次使用时，都是新的对象
3. 每个fixtures可以请求多个其他的fixtures
4. 可Cached
   每个生成的对象都被cached，不需要重新构造
5. 生存周期`Scope`: `function`, `class`, `module`, `package`, `session`

### `Fixtures`生存周期`Scope`

* `function`: 默认生存周期，存在于本测试用例
* `class`: 存在于当前类
* `module`: 存在与当前module
* `package`: 存在于当前package/文件夹
* `session`: 存在于当前session/整个测试过程

```python
## 本样例涉及fixture传递调用的特征

# Arrange
@pytest.fixture
def first_entry():
    return "a"

# Arrange
@pytest.fixture
def order(first_entry):
    return [first_entry]

def test_string(order):
    # Act
    order.append("b")
    # Assert
    assert order == ["a", "b"]

# ====> 等价于 ===>
entry = first_entry()
order = order(entry)
test_string(order)

```


```python
### 本样例涉及可重用、可Cache的特征
@pytest.fixture
def first_entry():
    return 'a'

@pytest.fixture
def order():
    return []


# 如果加上pytest.fixture标签，则order的内容会被cache，变成['a']
# 如果不加上pytest.fixture标签，则order的内容是原始的[]
# @pytest.fixture
def append_first(order, first_entry):
    order.append(first_entry)
    return order

```

## `Fixture` Teardown/Cleanup

1. 使用`yield`: 构造`object`完成之后通过`yield`导出，在`object`需要析构时，自动执行`yield object`后面的过程。遵循first-in-last-out原则，先构造的后析构。

```python
# mailbox.py
class MailBox:
    def __init__(self):
        self.box = []

    def put_in(self, mail):
        self.box.append(mail)
    
    def clear(self):
        self.box.clear()

# test_mailbox.py
@pytest.fixture
def mail_box():
    box = MailBox()
    yield box
    box.clear()

def test_box(mail, box):
    box.put_in(mail)
    assert [mail] == box.box
```

2. 使用`addfinalizer()`方法: 定义清理的函数，将定义的函数通过`request.addfinalizer()`注册到系统，由pytest自动在析构时执行。
   
```python
# test_mailbox.py
@pytest.fixture
def mail_box(request):
    box = MailBox()

    def clear_box():
        box.clear()
    request.addfinalizer(clear_box)

    return box

def test_box(mail, box):
    box.put_in(mail)
    assert [mail] == box.box
```

## `Fixture` Parameters

1. 使用`request`对象获得参数
```python
@pytest.fixture
def fixt(request):
    marker = request.node.get_closest_marker("fixt_data")
    if marker is None:
        # Handle missing marker in some way...
        data = None
    else:
        data = marker.args[0]
    # Do something with the data
    return data

@pytest.mark.fixt_data(42)
def test_fixt(fixt):
    assert fixt == 42
```

2. 返回函数变量，通过函数构造对象
```python
@pytest.fixture
def make_customer_record():
    def _make_customer_record(name):
        return {"name": name, "orders": []}

    return _make_customer_record


def test_customer_records(make_customer_record):
    customer_1 = make_customer_record("Lisa")
    customer_2 = make_customer_record("Mike")
    customer_3 = make_customer_record("Meredith")
```

3. 在`Fixture`上添加参数之后，可以重复根据参数构造多个对象，从而多次测试test_case

```python
# content of conftest.py
import pytest
import smtplib


@pytest.fixture(scope="module", params=["smtp.gmail.com", "mail.python.org"])
def smtp_connection(request):
    smtp_connection = smtplib.SMTP(request.param, 587, timeout=5)
    yield smtp_connection
    print("finalizing {}".format(smtp_connection))
    smtp_connection.close()
# 添加params之后，会生成两个smtp_connnect对象，
# 包括smtp_connection("smtp.gmail.com")和smtp_connection("mail.python.org")
```

# Mock

mock是unittest的一个特性，用于模拟对象的执行，提供返回值(return_value)、异常(side_effect)、替换执行对象(wraps)等。

