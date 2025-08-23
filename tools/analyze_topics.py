import os
import re
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import NMF
import nltk
from nltk.corpus import stopwords

# Descargar las stopwords de NLTK si no están ya descargadas
try:
    stopwords.words('spanish')
except LookupError:
    nltk.download('stopwords')

def preprocess_text(text):
    """
    Preprocesa el texto: minúsculas, elimina puntuación, números y stopwords.
    """
    text = text.lower()
    text = re.sub(r'\[\[p=\d+\]\]', '', text) # Eliminar marcadores de página
    text = re.sub(r'[^a-záéíóúüñ\s-]', '', text) # Eliminar puntuación y números, pero permitir guiones
    words = text.split()
    spanish_stopwords = set(stopwords.words('spanish'))
    words = [word for word in words if word not in spanish_stopwords and len(word) > 2]
    return " ".join(words)

def get_top_words(model, feature_names, n_top_words):
    """
    Obtiene las palabras principales para cada tema.
    """
    topics = []
    for topic_idx, topic in enumerate(model.components_):
        top_words = [feature_names[i] for i in topic.argsort()[:-n_top_words - 1:-1]]
        topics.append(f"Tema #{topic_idx}: {' '.join(top_words)}")
    return topics

def analyze_topics(input_dir, num_topics=10, num_top_words=10):
    """
    Realiza el modelado de temas en los documentos de un directorio.
    """
    documents = []
    filenames = []
    
    for filename in os.listdir(input_dir):
        if filename.endswith(".txt"):
            filepath = os.path.join(input_dir, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    documents.append(f.read())
                    filenames.append(filename)
            except IOError as e:
                print(f"Advertencia: No se pudo leer el archivo {filepath}. Error: {e}")

    if not documents:
        print(f"No se encontraron archivos .txt en {input_dir}")
        return [] # Return empty list if no documents

    print(f"Procesando {len(documents)} documentos...")

    # Preprocesar documentos
    preprocessed_documents = [preprocess_text(doc) for doc in documents]

    # Crear la matriz TF-IDF
    # min_df=2: Ignorar términos que aparecen en menos de 2 documentos. Ayuda a eliminar ruido.
    tfidf_vectorizer = TfidfVectorizer(max_df=0.95, min_df=2, stop_words=stopwords.words('spanish'))
    tfidf = tfidf_vectorizer.fit_transform(preprocessed_documents)

    print(f"Número de características (palabras) después de TF-IDF: {tfidf.shape[1]}")

    # Aplicar NMF
    nmf_model = NMF(n_components=num_topics, random_state=1) # Removed alpha and l1_ratio
    nmf_model.fit(tfidf)

    feature_names = tfidf_vectorizer.get_feature_names_out()
    topics = get_top_words(nmf_model, feature_names, num_top_words)

    print("\n--- Temas Identificados ---")
    for topic in topics:
        print(topic)
    print("---------------------------\n")
    return topics # Return the identified topics
    # Opcional: Mostrar los documentos más representativos para cada tema
    # print("\n--- Documentos por Tema ---")
    # W = nmf_model.transform(tfidf)
    # for i, topic in enumerate(nmf_model.components_):
    #     print(f"  - {filenames[doc_idx]} (Peso: {W[doc_idx, i]:.2f})")
    # print("---------------------------
")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Analiza temas en documentos de texto.")
    parser.add_argument("input_dir", type=str, help="Directorio con los archivos .txt procesados.")
    parser.add_argument("--num_topics", type=int, default=10, help="Número de temas a extraer.")
    parser.add_argument("--num_top_words", type=int, default=10, help="Número de palabras principales por tema.")
    args = parser.parse_args()

    analyze_topics(args.input_dir, args.num_topics, args.num_top_words)
