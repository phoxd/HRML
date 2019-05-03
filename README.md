## Attribute Parser
as per (HackerRank problem)[https://www.hackerrank.com/challenges/attribute-parser/problem]


### HRML Grammar
First attempt is made using BNF grammar using Haskell

```EBNF
<HRML> ::= <tag> { <tag> }
<tag> ::= <openTag> { <tag> } <closeTag>
<openTag> ::= '<' <id> { <id> '=' '"' <id> '"' } '>'
<closeTag> ::= '</' <id> '>'
<id> ::= [a-zA-Z0-9]
```

Example usage `findTerm "a~f" "<a f = \"ef\"></a>"`
