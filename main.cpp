#include <cmath>
#include <cstdio>
#include <vector>
#include <iostream>
#include <algorithm>
#include <map>
using namespace std;

class Node;
struct Tag {
  string name;
  map<string, string> attr;
  
  Tag(string _name) : name(_name) {}
  void add(string attrName, string attrVal) {
    attr.insert(pair<string, string>(attrName, attrVal));
  }
  string find(string attrName) {
    map<string, string>::iterator it = attr.find(attrName);
    if(attr.end() != it) {
      return it->second;
    } else {
      return "Not found!";
    }
  }
};

class Node {
private:
  struct Tag tag;
  vector<Node*> children;
public:
  Node(string name) : tag(name) {}
  string getTagName() { return tag.name; }
};



int main() {
    /* Enter your code here. Read input from STDIN. Print output to STDOUT */
     
    int tagCount = 0;
    int tagOut = 0;
    //cin >> tagCount >> tagOut;
    cout << "Tag count: " << tagCount << endl;
    cout << "Tag find: " << tagOut << endl;

    Node n("nodd");
    cout << n.getTagName();
    
    return 0;
}
