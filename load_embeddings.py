from embed_functions import image_embedder, neo_helper
from pathlib import Path

if __name__=='__main__':
    
    uri = "bolt://localhost:7687"
    user = 'neo4j'
    password = 'password'
    
    img_emb = image_embedder.ImageEmbedder()
    neo_emb = neo_helper.NeoProdEmbeddings(uri, user, password)
    
    IMAGE_DIR = '/Users/grantbeasley/Downloads/images/'
    images = Path(IMAGE_DIR)
    
    all_files = [image for folder in images.iterdir() if not folder.name == '.DS_Store' for image in folder.iterdir() if image.suffix == '.jpg']
    

    for file in all_files:
        prod_id = file.name.replace('.jpg', '') 
        print(prod_id)
        embedding = img_emb.create_embedding(file)
        neo_emb.add_prod_embedding(prod_id, embedding[0].tolist())
