{-
Grammar for HRML
<HRML> = <tag> { <tag> }
<tag> := <openTag> { <tag> } <closeTag>
<openTag> := '<' <id> { <id> '=' '"' <id> '"' } '>'
<closeTag> := '</' <id> '>'
<id> := [a-zA-Z0-9]
-}


import Data.Char (isAlphaNum)
import Debug.Trace (trace)
data Htag = Tag String [(String, String)] deriving Show
data Htree = Node Htag [Htree] deriving Show
data Token = OpenTag String | CloseTag String | AttrName String | AttrVal String deriving Show

token :: String -> [Token]
token [] = []
token (' ':xs) = token xs
token ('>':xs) = token xs
token ('<':'/':xs) = CloseTag name : token (drop (length name) xs)
  where name = getAlphaNum xs
token ('<':xs) = OpenTag name : token (drop (length name) xs)
  where name = getAlphaNum xs
token ('=':xs) = AttrVal val : token (drop (length val + 2) rmxs)
  where val = getAttrVal rmxs
        rmxs = dropWhile (==' ') xs
token xs = AttrName name : token (drop (length name) xs)
  where name = getAlphaNum xs


getAlphaNum :: String -> String
getAlphaNum xs = takeWhile isAlphaNum xs

getAttrVal :: String -> String
getAttrVal ('"':xs) = takeWhile (/= '"') xs

-- parse
getAttrTuples :: [Token] -> [(String, String)]
getAttrTuples (AttrName name:AttrVal val:xs) = (name, val) : getAttrTuples xs
getAttrTuples _ = []

--parseTag :: [Token] -> Maybe (HRML, [Token])
--extTag :: (HRML, [Token]) -> Maybe (HRML, [Token])

parse :: String -> [Htree]
parse s = case parseTag (token s) of
  (h, cs) -> h

parseTag :: [Token] -> ([Htree], [Token])
parseTag [] =   ([], [])
parseTag t@(OpenTag name:_) = case parseInnerTags t of
  --(h, CloseTag cname:cs) -> parseTag cs
  (h, cs) -> case parseTag cs of
    (h1, ds) -> (h ++ h1, [])

parseInnerTags :: [Token] -> ([Htree], [Token])
parseInnerTags [] = ([], [])
parseInnerTags (OpenTag name:xs) = (node:[], cs)
  where node = Node (Tag name attrs) children
        attrs = getAttrTuples xs
        rest = drop (2 * length attrs) xs
        (children, cs) = case parseInnerTags rest of
          (c, CloseTag _:cs) -> (c, cs)
          c -> c
parseInnerTags (CloseTag name:xs) = ([], xs)

-- retreive items
data TokenFind = Tagname String | Attrname String deriving Show
--data FindTag = TagAttr String String | ChildTag String FindTag deriving Show
tokenFind :: String -> [TokenFind]
tokenFind [] = []
tokenFind (' ':xs) = tokenFind xs
tokenFind ('\n':xs) = tokenFind xs
tokenFind ('~':xs) = Attrname attrName : tokenFind (drop (length attrName) xs)
  where attrName = getAlphaNum xs
tokenFind ('.':xs) = Tagname name : tokenFind (drop (length name) xs)
  where name = getAlphaNum xs
tokenFind xs = Tagname tagname : tokenFind (drop (length tagname) xs)
  where tagname = getAlphaNum xs

findTag :: [String] -> [Htree] -> Maybe Htree
findTag _ [] = Nothing
findTag [] _ = Nothing
findTag (x:xs) (node@(Node (Tag name _) cs):nodes)
  | x == name && not (null xs) = findTag xs cs
  | x == name = Just node
  | otherwise = findTag (x:xs) nodes

findAttr :: String -> [(String, String)] -> Maybe String
findAttr _ [] = Nothing
findAttr a (x:xs)
  | a == fst x = Just $ snd x
  | otherwise = findAttr a xs

findTerm :: String -> String -> String
findTerm searchTerm hrml =
  case findTag searchTagnames (parse hrml) of
    Just (Node (Tag name attrs) _) -> case findAttr attrTerm attrs of
      Just s -> s
      _ -> "No attribute found "
    _ -> "Nothing"
  where (tagnames, rest) = span (\c -> case c of Tagname _ -> True; _ -> False) (tokenFind searchTerm)
        searchTagnames = map (\c -> case c of Tagname n -> n) tagnames
        attrTerm = case head rest of (Attrname n) -> n
          

{-}
findParentTag :: [TokenFind] -> [Htree] -> String
findParentTag tagTokens@(Tagname name:xs) h = case findTag name h of
  Just node -> findTags tagTokens node
  _ -> "Not Found Parent Tag!\n" ++ findParentTag (tail rest) h
    where (_,rest) = span (\a -> case a of Tagname _ -> True; _ -> False) xs

findTags :: [TokenFind] -> Htree -> String
findTags (Tagname searchTag:Attrname searchAttr:xs) (Node (Tag tagName attrs) cs)
  | searchTag == tagName = findAttr searchAttr attrs
  | otherwise = "Not Found Tag!"
findTags (Tagname searchTag:xs) (Node (Tag tagName attrs) cs) 
  | searchTag == tagName = findParentTag xs cs
  | otherwise = "Not Found!"


findAttr :: String -> [(String, String)] -> String
findAttr _ [] = "No tuple found!"
findAttr a (x:xs)
  | a == fst x = snd x
  | otherwise = findAttr a xs

-}
