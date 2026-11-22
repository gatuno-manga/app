// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get authSignInTitle => 'Gatuno';

  @override
  String get authSignInSubtitle =>
      'O Gatuno é um sistema desenvolvido para organizar e compartilhar uma coleção pessoal de e-books em uma rede local.';

  @override
  String get authSignUpTitle => 'Junte-se ao Gatuno';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailError => 'Por favor, insira seu email';

  @override
  String get authEmailInvalid => 'Por favor, insira um email válido';

  @override
  String get authPasswordLabel => 'Senha';

  @override
  String get authPasswordError => 'Por favor, insira sua senha';

  @override
  String get authPasswordTooShort => 'A senha deve ter pelo menos 8 caracteres';

  @override
  String get authPasswordNoUppercase =>
      'A senha deve conter pelo menos uma letra maiúscula';

  @override
  String get authPasswordNoNumber => 'A senha deve conter pelo menos um número';

  @override
  String get authPasswordNoSymbol =>
      'A senha deve conter pelo menos um símbolo';

  @override
  String get authConfirmPasswordLabel => 'Confirmar Senha';

  @override
  String get authConfirmPasswordError => 'Por favor, confirme sua senha';

  @override
  String get authPasswordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get authSignInButton => 'ENTRAR';

  @override
  String get authSignUpButton => 'CADASTRAR';

  @override
  String get authCreateAccountButton => 'CRIAR CONTA';

  @override
  String get authDoNotHaveAccount => 'Não tem uma conta? Cadastre-se';

  @override
  String get authAlreadyHaveAccount => 'Já tem uma conta? Entrar';

  @override
  String get homeTitle => 'Início';

  @override
  String get homeFeaturedReadNow => 'Ler agora';

  @override
  String get homeContinueReadingTitle => 'Continue a sua leitura';

  @override
  String get homeLatestUpdatesTitle => 'Atualizações Recentes';

  @override
  String get homeRecentlyAddedTitle => 'Novidades no Gatuno';

  @override
  String get homeViewAll => 'Ver tudo';

  @override
  String get booksTitle => 'Livros';

  @override
  String get booksSearchHint => 'Pesquisar livros...';

  @override
  String get booksFilterTitle => 'Filtros';

  @override
  String get booksApplyFilters => 'Aplicar Filtros';

  @override
  String get booksClearFilters => 'Limpar';

  @override
  String get booksPublicationYear => 'Ano de publicação';

  @override
  String get booksTypes => 'Tipos';

  @override
  String get booksSensitiveContent => 'Conteúdos sensíveis';

  @override
  String get booksTags => 'Tags';

  @override
  String get booksIncludedTags => 'Selecionadas';

  @override
  String get booksExcludedTags => 'Excluídas';

  @override
  String get booksAuthors => 'Autores';

  @override
  String get booksFilterAdd => 'Adicionar';

  @override
  String get booksFilterSearchHint => 'Buscar...';

  @override
  String get booksFilterNoOptions => 'Nenhuma opção encontrada';

  @override
  String get booksFilterLoadError => 'Não foi possível carregar as opções';

  @override
  String get booksFilterRetry => 'Tentar novamente';

  @override
  String get booksFilterDone => 'Concluir';

  @override
  String get booksFilterLogicAll => 'Todos';

  @override
  String get booksFilterLogicAny => 'Qualquer';

  @override
  String get booksOperatorBefore => 'Antes de';

  @override
  String get booksOperatorBeforeEqual => 'Antes ou igual a';

  @override
  String get booksOperatorAfter => 'Depois de';

  @override
  String get booksOperatorAfterEqual => 'Depois ou igual a';

  @override
  String get booksOperatorEqual => 'Igual a';

  @override
  String get bookTypeManga => 'Mangá';

  @override
  String get bookTypeManhwa => 'Manhwa';

  @override
  String get bookTypeManhua => 'Manhua';

  @override
  String get bookTypeBook => 'Livro';

  @override
  String get bookTypeOther => 'Outro';

  @override
  String get bookTypeUnknown => 'Desconhecido';

  @override
  String get booksUnknownAuthor => 'Autor Desconhecido';

  @override
  String get booksNoBooksFound => 'Nenhum livro encontrado';

  @override
  String get booksOfflineNotice => 'Mostrando os livros salvos neste aparelho.';

  @override
  String get booksOfflineFiltersNotice =>
      'Alguns filtros podem esconder livros que ainda não foram abertos.';

  @override
  String get booksOfflinePagingPaused =>
      'Puxe para atualizar e ver os livros salvos neste aparelho.';

  @override
  String get booksOfflineRefreshAction =>
      'mostrar os livros salvos neste aparelho';

  @override
  String get booksOfflineNoMatch =>
      'Nenhum livro salvo corresponde. Tente limpar os filtros ou reconectar.';

  @override
  String get booksOfflineEndOfList => 'Fim dos livros salvos neste aparelho';

  @override
  String get booksFilterOfflineNotSaved =>
      'Estas opções ainda não estão salvas neste aparelho. Vão carregar quando o servidor voltar a responder.';

  @override
  String get booksNoChaptersFound => 'Nenhum capítulo encontrado';

  @override
  String get booksChapterCount => 'Capítulos';

  @override
  String booksChapterLabel(String index) {
    return 'Capítulo $index';
  }

  @override
  String get booksSortTitle => 'Ordenar';

  @override
  String get booksSortMostRecentAdded => 'Adicionados recentemente';

  @override
  String get booksSortOldestAdded => 'Mais antigos primeiro';

  @override
  String get booksSortAlphabeticalAZ => 'Alfabética A-Z';

  @override
  String get booksSortAlphabeticalZA => 'Alfabética Z-A';

  @override
  String get booksSortMostRecentUpdate => 'Atualizações recentes';

  @override
  String get booksSortOldestUpdate => 'Atualizações antigas';

  @override
  String get booksSortMostRecentPublished => 'Publicados recentemente';

  @override
  String get booksSortOldestPublished => 'Publicados antigos';

  @override
  String get booksViewOptions => 'Opções de visualização';

  @override
  String get booksViewGrid => 'Grade';

  @override
  String get booksViewList => 'Lista';

  @override
  String get booksViewCover => 'Capas';

  @override
  String get booksViewColumns => 'Colunas';

  @override
  String get booksViewNavigation => 'Navegação';

  @override
  String get booksViewNavigationPages => 'Páginas';

  @override
  String get booksViewNavigationInfinite => 'Rolagem infinita';

  @override
  String get scrapingStatusReady => 'Pronto';

  @override
  String get scrapingStatusProcess => 'Processando';

  @override
  String get scrapingStatusError => 'Erro';

  @override
  String get scrapingStatusProcessWarning =>
      'Este capítulo ainda está sendo processado e ainda não está disponível para leitura.';

  @override
  String get scrapingStatusErrorWarning =>
      'Este capítulo encontrou um erro durante o processamento e não pode ser lido.';

  @override
  String get booksStartReading => 'Começar a ler';

  @override
  String get booksContinueReading => 'Continuar a ler';

  @override
  String get homeWelcome => 'Bem-vindo ao Gatuno!';

  @override
  String get homeProfile => 'Perfil';

  @override
  String get homeSignIn => 'Entrar';

  @override
  String get userMeTitle => 'Meu Perfil';

  @override
  String get userMeSensitiveContent => 'Conteúdo Sensível';

  @override
  String get userMeSensitiveContentDesc =>
      'Mostrar livros com conteúdo sensível';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsThemeTitle => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsThemeTrueDark => 'Preto absoluto';

  @override
  String get settingsThemeDracula => 'Dracula';

  @override
  String get settingsThemeSlate => 'Ardósia';

  @override
  String get settingsGeneralSection => 'Geral';

  @override
  String get settingsReadingSection => 'Leitura';

  @override
  String get settingsApiSection => 'Configuração da API';

  @override
  String get settingsApiUrlLabel => 'URL Base da API';

  @override
  String get settingsApiUrlHint => 'http://sua-api.com/api';

  @override
  String get settingsApiUrlSuccess => 'URL da API atualizada com sucesso';

  @override
  String get settingsApiUrlError => 'Erro ao atualizar a URL da API';

  @override
  String get settingsServerChangeTitle => 'Trocar de servidor?';

  @override
  String settingsServerChangeBody(int count, String size) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Os $countString capítulos dos seus downloads ($size) serão apagados, e a biblioteca offline salva neste aparelho será limpa.',
      one:
          'O capítulo dos seus downloads ($size) será apagado, e a biblioteca offline salva neste aparelho será limpa.',
    );
    return '$_temp0';
  }

  @override
  String get settingsServerChangeBodyUnknown =>
      'Os downloads e a biblioteca offline salvos neste aparelho serão apagados.';

  @override
  String get settingsServerChangeConfirm => 'Trocar e apagar';

  @override
  String get settingsAllowedUrlsSection => 'Certificados Inválidos Permitidos';

  @override
  String get settingsAddUrlLabel => 'Adicionar URL';

  @override
  String get settingsAddUrlHint => 'https://exemplo.com';

  @override
  String get settingsRemoveUrl => 'Remover';

  @override
  String get settingsCertificatesSection => 'Certificados';

  @override
  String get settingsCertificatesDesc =>
      'Gerenciar certificados confiáveis e ignorados';

  @override
  String get settingsDownloadsSection => 'Downloads';

  @override
  String get settingsDownloadNetwork => 'Rede para downloads';

  @override
  String get settingsDownloadNetworkDesc =>
      'Escolha quando baixar cada tipo de livro';

  @override
  String get settingsDownloadTitle => 'Downloads';

  @override
  String get settingsDownloadWifiOnly => 'Só Wi-Fi';

  @override
  String get settingsDownloadWifiAndMobile => 'Wi-Fi e dados';

  @override
  String get settingsDownloadOtherHint => 'Inclui livros sem tipo';

  @override
  String get settingsDownloadNetworkNotice =>
      'Ao trocar para Só Wi-Fi, downloads em andamento por dados móveis pausam até haver Wi-Fi, e arquivos que estavam pela metade recomeçam do zero. As mudanças valem na hora.';

  @override
  String get settingsDownloadSaveError =>
      'Não foi possível salvar. A regra anterior foi mantida.';

  @override
  String get settingsDiagnosticsSection => 'Diagnósticos';

  @override
  String get settingsExportLogs => 'Exportar Logs';

  @override
  String get settingsExportLogsDesc => 'Compartilhar o arquivo de log do app';

  @override
  String get settingsOpenLogs => 'Abrir Logs';

  @override
  String get settingsOpenLogsDesc => 'Visualizar logs neste dispositivo';

  @override
  String get certTrustDialogTitle => 'Certificado não confiável';

  @override
  String certTrustDialogMessage(String name) {
    return 'O servidor em $name está usando um certificado não confiável. Deseja confiar nele e continuar?';
  }

  @override
  String get certTrustDialogTrust => 'Confiar';

  @override
  String get certTrustDialogIgnore => 'Ignorar';

  @override
  String get certTrustedTab => 'Confiáveis';

  @override
  String get certIgnoredTab => 'Ignorados';

  @override
  String get certAddTitle => 'Adicionar Certificado';

  @override
  String get certAddLabel => 'Nome';

  @override
  String get certAddHint => 'api.exemplo.com';

  @override
  String get certAddPemLabel => 'Certificado (PEM)';

  @override
  String get certAddFileButton => 'Selecionar Arquivo PEM';

  @override
  String get certEmptyTrusted => 'Nenhum certificado confiável ainda.';

  @override
  String get certEmptyIgnored => 'Nenhum certificado ignorado ainda.';

  @override
  String certFingerprintLabel(String fingerprint) {
    return 'Impressão digital: $fingerprint';
  }

  @override
  String get certDeleteConfirm =>
      'Tem certeza que deseja remover este certificado?';

  @override
  String get certErrorInvalidFormat => 'Formato de certificado inválido.';

  @override
  String get certErrorFileMissing =>
      'Arquivo de certificado ausente ou ilegível.';

  @override
  String get certErrorDecoding =>
      'Falha ao decodificar o arquivo de certificado.';

  @override
  String get certErrorEmptyFingerprint =>
      'Falha ao calcular a impressão digital do certificado.';

  @override
  String get certErrorUnknown =>
      'Ocorreu um erro inesperado ao adicionar o certificado.';

  @override
  String get welcomeTitle => 'Bem-vindo ao Gatuno';

  @override
  String get welcomeInstructions =>
      'Por favor, insira a URL da API do seu servidor para continuar.';

  @override
  String get welcomeConnect => 'Conectar';

  @override
  String get commonLogout => 'Sair';

  @override
  String get commonLoading => 'Carregando...';

  @override
  String get commonGuest => 'Visitante';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get errorTitle => 'Algo deu errado';

  @override
  String get errorMessage => 'Ocorreu um erro inesperado.';

  @override
  String get errorRetry => 'Tentar novamente';

  @override
  String get errorBack => 'Voltar';

  @override
  String get commonPrevious => 'Anterior';

  @override
  String get commonNext => 'Próximo';

  @override
  String commonPage(int page) {
    return 'Página $page';
  }

  @override
  String commonPageOf(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get readingDeferredDocumentMessage =>
      'O suporte para PDF e EPUB estará disponível em breve.';

  @override
  String get readingNextChapter => 'Próximo Capítulo';

  @override
  String get readingPreviousChapter => 'Capítulo Anterior';

  @override
  String get readingPreviousChapterNotDownloaded =>
      'Capítulo Anterior (não baixado)';

  @override
  String get readingNextChapterNotDownloaded =>
      'Próximo Capítulo (não baixado)';

  @override
  String get readingStillOffline => 'Ainda offline.';

  @override
  String get readingFinished => 'Você chegou ao fim deste capítulo.';

  @override
  String get readingSettingsTitle => 'Ajustes de leitura';

  @override
  String get readingSettingsAction => 'Ajustes';

  @override
  String get readingThemeTitle => 'Tema de leitura';

  @override
  String get readingThemeStandard => 'Padrão';

  @override
  String get readingThemeSepia => 'Sépia';

  @override
  String get readingThemeCream => 'Creme';

  @override
  String get readingThemeHighContrast => 'Alto contraste';

  @override
  String get readingFontFamily => 'Fonte';

  @override
  String get readingFontFamilyDesc => 'Família do texto';

  @override
  String get readingFontSerif => 'Serifa';

  @override
  String get readingFontSans => 'Sem serifa';

  @override
  String get readingFontLexend => 'Lexend';

  @override
  String get readingFontAtkinson => 'Atkinson Hyperlegible';

  @override
  String get readingFontOpenDyslexic => 'OpenDyslexic';

  @override
  String readingFontSize(int size) {
    return 'Tamanho da fonte (${size}px)';
  }

  @override
  String get readingFontSizeDesc => 'A- / A+';

  @override
  String get readingDecreaseFontSize => 'Diminuir tamanho da fonte';

  @override
  String get readingIncreaseFontSize => 'Aumentar tamanho da fonte';

  @override
  String readingLineHeight(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 1,
        );
    final String valueString = valueNumberFormat.format(value);

    return 'Espaçamento de linhas ($valueString)';
  }

  @override
  String get readingLineHeightDesc => 'Distância entre linhas';

  @override
  String get readingDecreaseLineHeight => 'Diminuir espaçamento de linhas';

  @override
  String get readingIncreaseLineHeight => 'Aumentar espaçamento de linhas';

  @override
  String get readingAlignment => 'Alinhamento';

  @override
  String get readingAlignmentDesc => 'Esquerda, centro ou justificado';

  @override
  String get readingAlignLeft => 'Esquerda';

  @override
  String get readingAlignCenter => 'Centro';

  @override
  String get readingAlignJustify => 'Justificado';

  @override
  String booksDocumentFormat(String format) {
    return 'Formato: $format';
  }

  @override
  String get booksUnknownFormat => 'Desconhecido';

  @override
  String get bookRequestsTitle => 'Pedidos de Livros';

  @override
  String get bookRequestsEmpty => 'Nenhum pedido encontrado.';

  @override
  String get bookRequestsCreateTitle => 'Novo Pedido';

  @override
  String get bookRequestsFormTitle => 'Título do Livro';

  @override
  String get bookRequestsFormAuthor => 'Autor';

  @override
  String get bookRequestsFormSubmit => 'Enviar Pedido';

  @override
  String get bookRequestsSuccess => 'Solicitação criada com sucesso!';

  @override
  String get homeCtaTitle => 'Não encontrou o que procura?';

  @override
  String get homeCtaDescription =>
      'Solicite a adição de um novo livro ao nosso acervo. Avaliaremos o mais breve possível.';

  @override
  String get bookRequestsFormUrl => 'URL';

  @override
  String get bookRequestsFormReason => 'Motivo (opcional)';

  @override
  String get homeCtaSignInButton => 'Faça Login para Solicitar';

  @override
  String get homeCtaOfflineNote =>
      'Disponível quando você estiver online de novo.';

  @override
  String get bookRequestsFormTitleRequired => 'Por favor, insira um título';

  @override
  String get bookRequestsFormUrlRequired => 'Por favor, insira uma URL';

  @override
  String get bookRequestsFormUrlInvalid => 'Por favor, insira uma URL válida';

  @override
  String get bookRequestsCardUrl => 'URL';

  @override
  String get bookRequestsCardReason => 'Motivo';

  @override
  String get bookRequestsCardRejection => 'Mensagem de Rejeição';

  @override
  String bookRequestsCardDate(String date) {
    return 'Solicitado em $date';
  }

  @override
  String get bookRequestStatusPending => 'PENDENTE';

  @override
  String get bookRequestStatusApproved => 'APROVADO';

  @override
  String get bookRequestStatusRejected => 'REJEITADO';

  @override
  String get userImageEditAvatar => 'Alterar foto de perfil';

  @override
  String get userImageEditBanner => 'Alterar imagem do banner';

  @override
  String get userImageSourceGallery => 'Escolher da galeria';

  @override
  String get userImageSourceCamera => 'Tirar uma foto';

  @override
  String get userImageErrorType => 'Use uma imagem PNG, JPEG ou WebP.';

  @override
  String userImageErrorTooLarge(int maxMb) {
    return 'Esta imagem é grande demais. O limite é $maxMb MB.';
  }

  @override
  String get userImageErrorForbidden =>
      'Você não tem permissão para alterar esta imagem.';

  @override
  String get userImageErrorNetwork =>
      'Não foi possível enviar a imagem. Verifique sua conexão e tente novamente.';

  @override
  String get userImageErrorUnknown =>
      'Algo deu errado com esta imagem. Tente novamente.';

  @override
  String get mfaTitle => 'Autenticação em dois fatores';

  @override
  String get mfaStatusEnabled => 'A autenticação em dois fatores está ativada';

  @override
  String get mfaStatusDisabled =>
      'A autenticação em dois fatores está desativada';

  @override
  String mfaBackupCodesRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count códigos de backup restantes',
      one: '1 código de backup restante',
      zero: 'Nenhum código de backup restante',
    );
    return '$_temp0';
  }

  @override
  String get mfaEnableButton => 'Ativar';

  @override
  String get mfaDisableButton => 'Desativar';

  @override
  String get mfaReconfigureButton => 'Reconfigurar';

  @override
  String get mfaReconfigureTitle =>
      'Reconfigurar a autenticação em dois fatores?';

  @override
  String get mfaReconfigureWarning =>
      'Seu autenticador atual e todos os códigos de backup deixarão de funcionar imediatamente.';

  @override
  String get mfaReconfigureConfirm => 'Reconfigurar';

  @override
  String get mfaDisableTitle => 'Desativar autenticação em dois fatores';

  @override
  String get mfaDisableDescription =>
      'Informe um código do seu aplicativo autenticador ou um código de backup.';

  @override
  String get mfaDisableConfirm => 'Desativar';

  @override
  String get mfaSetupInstructions =>
      'Adicione este segredo ao seu aplicativo autenticador (ou gerenciador de senhas) e informe o código de 6 dígitos exibido.';

  @override
  String get mfaCopySecret => 'Copiar segredo';

  @override
  String get mfaOpenAuthenticator => 'Abrir no aplicativo autenticador';

  @override
  String get mfaCopied => 'Copiado';

  @override
  String get mfaConfirmButton => 'Confirmar';

  @override
  String get mfaBackupCodesTitle => 'Guarde seus códigos de backup';

  @override
  String get mfaBackupCodesWarning =>
      'Cada código funciona uma vez caso você perca o acesso ao autenticador. Eles não serão exibidos novamente.';

  @override
  String get mfaShareCodes => 'Salvar ou compartilhar';

  @override
  String get mfaCopyCodes => 'Copiar todos';

  @override
  String get mfaSavedConfirm => 'Eu guardei estes códigos';

  @override
  String get mfaDoneButton => 'Concluir';

  @override
  String get mfaRetryButton => 'Tentar novamente';

  @override
  String get mfaCodeLabel => 'Código de autenticação';

  @override
  String get mfaCodeRequired => 'Informe seu código de autenticação';

  @override
  String get mfaChallengeTitle => 'Confirme que é você';

  @override
  String get mfaChallengeDescription =>
      'Informe o código de 6 dígitos do seu aplicativo autenticador ou um código de backup.';

  @override
  String get mfaVerifyButton => 'Verificar';

  @override
  String get mfaErrorInvalidCode => 'Código inválido. Tente novamente.';

  @override
  String get mfaErrorTooManyAttempts =>
      'Muitas tentativas. Aguarde um minuto e tente novamente.';

  @override
  String get mfaErrorChallengeExpired =>
      'A verificação expirou. Entre novamente.';

  @override
  String get mfaErrorNetwork =>
      'Não foi possível acessar o servidor. Verifique sua conexão.';

  @override
  String get mfaErrorUnknown => 'Algo deu errado. Tente novamente.';

  @override
  String get settingsMfaDesc =>
      'Proteja sua conta com um aplicativo autenticador';

  @override
  String get mfaNoAuthenticatorApp =>
      'Não foi possível abrir um aplicativo autenticador. Copie o segredo e adicione manualmente.';

  @override
  String get mfaSaveCodesFirst =>
      'Guarde seus códigos de backup antes de sair desta tela.';

  @override
  String get appLockTitle => 'Bloqueio do app';

  @override
  String get settingsAppLockDesc =>
      'Exigir sua digital, rosto ou PIN do aparelho para abrir o Gatuno';

  @override
  String get appLockSwitchTitle => 'Bloquear o Gatuno';

  @override
  String get appLockSwitchDesc =>
      'Pedir sua digital, rosto ou PIN do aparelho ao abrir o app';

  @override
  String get appLockSwitchDescBiometricOnly =>
      'Pedir sua digital ou rosto ao abrir o app';

  @override
  String get appLockUnsupportedDesc =>
      'Este aparelho não tem bloqueio de tela, então o Gatuno não pode ser bloqueado.';

  @override
  String get appLockUnsupportedEnabledDesc =>
      'Este aparelho não tem bloqueio de tela. Defina um nos ajustes do sistema para desbloquear o Gatuno ou desativar o bloqueio.';

  @override
  String get appLockGraceTitle => 'Bloquear depois de sair do app';

  @override
  String get appLockGraceImmediately => 'Imediatamente';

  @override
  String get appLockGraceThirtySeconds => 'Após 30 segundos';

  @override
  String get appLockGraceOneMinute => 'Após 1 minuto';

  @override
  String get appLockGraceFiveMinutes => 'Após 5 minutos';

  @override
  String get appLockGraceFifteenMinutes => 'Após 15 minutos';

  @override
  String get appLockFallbackTitle =>
      'Permitir PIN, padrão ou senha do aparelho';

  @override
  String get appLockFallbackOnDesc =>
      'Usado quando sua digital ou rosto não estiver disponível. Desativar isto pode deixar você sem acesso ao Gatuno após um bloqueio da biometria.';

  @override
  String get appLockFallbackOffDesc =>
      'Se a biometria for bloqueada, o Gatuno fica bloqueado até o aparelho liberá-la de novo.';

  @override
  String get appLockConfirmReason =>
      'Confirme que é você para alterar o bloqueio do app';

  @override
  String get appLockFallbackNeedsBiometric =>
      'Cadastre uma digital ou rosto nos ajustes do sistema antes de desativar o PIN do aparelho.';

  @override
  String get appLockFallbackNoSensor =>
      'Este aparelho não tem sensor de digital ou rosto, então o PIN do aparelho precisa continuar permitido.';

  @override
  String get appLockEnableNeedsBiometric =>
      'Permita o PIN do aparelho abaixo ou cadastre uma digital ou rosto nos ajustes do sistema.';

  @override
  String get appLockPromptHint => 'Use sua digital ou rosto';

  @override
  String get appLockPromptHintWithCredential =>
      'Use sua digital, rosto ou PIN do aparelho';

  @override
  String get appLockPromptReason => 'Desbloquear o Gatuno';

  @override
  String get appLockLockedTitle => 'O Gatuno está bloqueado';

  @override
  String get appLockLockedDesc =>
      'Use sua digital, rosto ou PIN do aparelho para continuar';

  @override
  String get appLockLockedDescBiometricOnly =>
      'Use sua digital ou rosto para continuar';

  @override
  String get appLockUnlockButton => 'Desbloquear';

  @override
  String get appLockRetryButton => 'Tentar novamente';

  @override
  String get appLockErrorCancelled => 'Desbloqueio cancelado';

  @override
  String get appLockErrorLockedOut =>
      'Muitas tentativas. A biometria está bloqueada por enquanto.';

  @override
  String get appLockErrorNoCredentials =>
      'Este aparelho não tem bloqueio de tela. Defina um nos ajustes do sistema.';

  @override
  String get appLockErrorNoBiometrics =>
      'Nenhuma digital ou rosto está cadastrado neste aparelho. Cadastre um nos ajustes do sistema para desbloquear o Gatuno.';

  @override
  String get appLockErrorNoBiometricHardware =>
      'Nenhum sensor de digital ou rosto está disponível neste aparelho.';

  @override
  String get appLockErrorSave =>
      'Não foi possível salvar a configuração. Tente novamente.';

  @override
  String get appLockErrorUnavailable =>
      'A autenticação do aparelho não está disponível agora. Tente novamente em instantes.';

  @override
  String get appLockErrorFailed =>
      'Não foi possível confirmar que é você. Tente novamente.';

  @override
  String get readingAccessibilityTitle => 'Acessibilidade';

  @override
  String get readingAccessibilityDesc =>
      'Modo dislexia, espaçamento, largura da linha, régua';

  @override
  String get readingDyslexiaTitle => 'Modo dislexia';

  @override
  String get readingDyslexiaDesc =>
      'Aplica de uma vez as recomendações de legibilidade. Você ainda pode ajustar cada item abaixo.';

  @override
  String readingChipFont(String name) {
    return 'Fonte $name';
  }

  @override
  String readingChipAlignment(String name) {
    return 'Alinhamento: $name';
  }

  @override
  String readingChipLetters(String percent) {
    return 'Letras +$percent%';
  }

  @override
  String readingChipWords(String percent) {
    return 'Palavras +$percent%';
  }

  @override
  String readingChipLine(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 1,
        );
    final String valueString = valueNumberFormat.format(value);

    return 'Linha $valueString';
  }

  @override
  String readingChipWidth(int chars) {
    return '~$chars caracteres';
  }

  @override
  String readingChipBackground(String name) {
    return 'Fundo $name';
  }

  @override
  String get readingChipNoItalics => 'Sem itálico';

  @override
  String get readingChipRuler => 'Régua de leitura';

  @override
  String readingLetterSpacing(int percent) {
    return 'Espaço entre letras (+$percent%)';
  }

  @override
  String get readingLetterSpacingDesc => 'Separa melhor as letras';

  @override
  String get readingDecreaseLetterSpacing => 'Diminuir espaço entre letras';

  @override
  String get readingIncreaseLetterSpacing => 'Aumentar espaço entre letras';

  @override
  String readingWordSpacing(int percent) {
    return 'Espaço entre palavras (+$percent%)';
  }

  @override
  String get readingWordSpacingDesc => 'Separa melhor as palavras';

  @override
  String get readingDecreaseWordSpacing => 'Diminuir espaço entre palavras';

  @override
  String get readingIncreaseWordSpacing => 'Aumentar espaço entre palavras';

  @override
  String readingLineWidth(int chars) {
    return 'Largura da linha ($chars caracteres)';
  }

  @override
  String get readingLineWidthOff => 'Largura da linha (sem limite)';

  @override
  String get readingLineWidthDesc => 'Mantém as linhas curtas';

  @override
  String get readingDecreaseLineWidth => 'Diminuir largura da linha';

  @override
  String get readingIncreaseLineWidth => 'Aumentar largura da linha';

  @override
  String get readingSuppressItalics => 'Sem itálico';

  @override
  String get readingSuppressItalicsDesc =>
      'Mostra o texto em ênfase como normal';

  @override
  String get readingRulerTitle => 'Régua de leitura';

  @override
  String get readingRulerDesc => 'Destaca a linha atual';

  @override
  String get readingRulerSemantics =>
      'Régua de leitura. Deslize para cima ou para baixo para movê-la.';

  @override
  String get offlineBannerMessage => 'Offline: mostrando dados salvos';

  @override
  String get offlineEmptyTitle => 'Você está offline';

  @override
  String get offlineEmptyMessage =>
      'Isto ainda não está salvo neste aparelho. Vai carregar quando o servidor voltar a responder.';

  @override
  String get downloadsNotificationRunningTitle => 'Baixando capítulos';

  @override
  String downloadsNotificationRunningBody(String finished, String total) {
    return '$finished de $total arquivos';
  }

  @override
  String get downloadsNotificationCompleteTitle => 'Downloads concluídos';

  @override
  String downloadsNotificationCompleteBody(String total) {
    return '$total arquivos baixados';
  }

  @override
  String get downloadsNotificationErrorTitle => 'Alguns downloads falharam';

  @override
  String downloadsNotificationErrorBody(String failed, String total) {
    return '$failed de $total arquivos falharam';
  }

  @override
  String get booksSelect => 'Selecionar';

  @override
  String get booksMoreOptions => 'Mais opções';

  @override
  String booksDownloadsSummaryOfTotal(int done, int total, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done de $total capítulos baixados · $size',
      one: '$done de 1 capítulo baixado · $size',
    );
    return '$_temp0';
  }

  @override
  String booksDownloadsSummary(int done, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      done,
      locale: localeName,
      other: '$done capítulos baixados · $size',
      one: '1 capítulo baixado · $size',
    );
    return '$_temp0';
  }

  @override
  String booksDownloadsPhaseActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Baixando $count capítulos',
      one: 'Baixando 1 capítulo',
    );
    return '$_temp0';
  }

  @override
  String get booksDownloadsPhaseWaitingWifi => 'Aguardando Wi-Fi';

  @override
  String get booksDownloadsPhaseWaitingConnection => 'Aguardando conexão';

  @override
  String booksDownloadsPhasePaused(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capítulos pausados',
      one: '1 capítulo pausado',
    );
    return '$_temp0';
  }

  @override
  String booksDownloadsPhaseFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capítulos falharam',
      one: '1 capítulo falhou',
    );
    return '$_temp0';
  }

  @override
  String get booksDownloadsPauseAll => 'Pausar tudo';

  @override
  String get booksDownloadsResumeAll => 'Retomar';

  @override
  String booksDownloadsRetryFailed(int count) {
    return 'Tentar de novo ($count)';
  }

  @override
  String booksSelectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionados',
      one: '1 selecionado',
      zero: 'Nenhum selecionado',
    );
    return '$_temp0';
  }

  @override
  String get booksSelectionClose => 'Sair da seleção';

  @override
  String get booksSelectionSelectLoaded => 'Selecionar capítulos carregados';

  @override
  String get booksSelectionDownload => 'Baixar';

  @override
  String get booksSelectionDelete => 'Excluir';

  @override
  String get booksSelectionPause => 'Pausar';

  @override
  String get booksSelectionResume => 'Retomar';

  @override
  String get booksSelectionRetry => 'Tentar';

  @override
  String get booksOptionsTitle => 'Opções do livro';

  @override
  String get booksOptionsDownloads => 'Downloads';

  @override
  String get booksDownloadAll => 'Baixar todos';

  @override
  String get booksDownloadAllSubtitle =>
      'Inclui capítulos ainda não carregados';

  @override
  String get booksDownloadAllOffline => 'Precisa de conexão com o servidor';

  @override
  String get booksDeleteAllDownloads => 'Excluir todos os downloads';

  @override
  String booksDeleteAllDownloadsSubtitle(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capítulos · $size',
      one: '1 capítulo · $size',
    );
    return '$_temp0';
  }

  @override
  String get booksAutoDownload => 'Baixar novos capítulos';

  @override
  String get booksAutoDownloadSubtitle =>
      'Baixa automaticamente os capítulos novos deste livro';

  @override
  String get booksChapterDownloadFailed => 'O download falhou';

  @override
  String booksChapterDownloaded(String size) {
    return 'Baixado · $size';
  }

  @override
  String get booksChapterDownloadRetry => 'Tentar novamente';

  @override
  String get booksChapterDownloadDelete => 'Excluir download';

  @override
  String get booksDownloadErrorSignIn =>
      'Entre de novo para baixar este capítulo.';

  @override
  String get booksDownloadErrorStorageFull =>
      'Não há espaço livre suficiente neste aparelho.';

  @override
  String get booksDownloadErrorNotFound =>
      'O servidor não tem mais este capítulo.';

  @override
  String get booksDownloadErrorTimedOut =>
      'Um arquivo demorou demais para baixar.';

  @override
  String get booksDownloadErrorServer =>
      'O servidor não conseguiu enviar este capítulo.';

  @override
  String get booksDownloadErrorUnknown => 'Algo deu errado durante o download.';

  @override
  String booksDeleteChaptersTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Excluir $count capítulos?',
      one: 'Excluir 1 capítulo?',
    );
    return '$_temp0';
  }

  @override
  String booksDeleteChaptersBody(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Os $count capítulos serão excluídos deste aparelho e liberarão $size. Você pode baixá-los de novo depois.',
      one:
          'O capítulo será excluído deste aparelho e liberará $size. Você pode baixá-lo de novo depois.',
    );
    return '$_temp0';
  }

  @override
  String get booksDeleteAllTitle => 'Excluir todos os downloads deste livro?';

  @override
  String get booksDeleteConfirm => 'Excluir';

  @override
  String get booksDownloadSignInRequired => 'Entre para baixar capítulos.';

  @override
  String get booksDownloadSignIn => 'Entrar';

  @override
  String get booksDownloadActionFailed =>
      'Não foi possível atualizar os downloads. Tente de novo.';

  @override
  String get booksDownloadStatusNone => 'Não baixado';

  @override
  String get booksDownloadStatusQueued => 'Na fila';

  @override
  String booksDownloadStatusRunning(int percent) {
    return 'Baixando, $percent%';
  }

  @override
  String get booksDownloadStatusWaitingWifi => 'Aguardando Wi-Fi';

  @override
  String get booksDownloadStatusWaitingConnection => 'Aguardando conexão';

  @override
  String get booksDownloadStatusPaused => 'Pausado';

  @override
  String get booksDownloadStatusFailed => 'O download falhou';

  @override
  String get booksDownloadStatusDone => 'Baixado';

  @override
  String get booksDownloadHintDownload => 'Toque para baixar';

  @override
  String get booksDownloadHintPause => 'Toque para pausar';

  @override
  String get booksDownloadHintResume => 'Toque para retomar';

  @override
  String get booksDownloadHintOptions => 'Toque para ver opções';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryComingSoonTitle => 'Em breve';

  @override
  String get libraryComingSoonBody => 'A sua biblioteca chega em breve.';
}
